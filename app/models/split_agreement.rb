class SplitAgreement < ApplicationRecord
  belongs_to :project
  has_many :split_entries, dependent: :destroy
  has_many :participants, through: :split_entries, source: :user

  enum :status, { draft: 0, pending: 1, locked: 2 }

  # Validations
  validates :project_id, uniqueness: true
  validates :verification_token, presence: true, uniqueness: true
  validate :percentage_total_must_be_100, if: :pending_or_locked?
  validate :all_entries_must_be_approved, if: :locked?

  # Callbacks
  before_create :generate_verification_token
  before_update :set_locked_at, if: :will_save_change_to_status_to_locked?

  # Instance methods
  def all_approved?
    split_entries.pending_approval.none?
  end

  def total_percentage
    split_entries.sum(:percentage)
  end

  def valid_percentages?
    total = total_percentage.to_f.round(2)
    (99.99..100.01).cover?(total)
  end

  def can_lock?
    pending? && all_approved? && valid_percentages?
  end

  def auto_lock!
    return unless can_lock?

    transaction do
      lock!  # Pessimistic lock to prevent race conditions
      update!(status: :locked, locked_at: Time.current) if pending?
    end
  end

  def propose!
    return false unless draft? && valid_percentages?

    transaction do
      # Auto-approve owner's entry
      owner_entry = split_entries.find_by(user: project.owner)
      owner_entry&.update!(approved_at: Time.current)

      update!(status: :pending)
    end
  end

  def immutable?
    locked?
  end

  def to_param
    verification_token
  end

  private

  def pending_or_locked?
    pending? || locked?
  end

  def percentage_total_must_be_100
    unless valid_percentages?
      total = total_percentage.to_f.round(2)
      errors.add(:base, "Total percentage must equal 100% (currently #{total}%)")
    end
  end

  def all_entries_must_be_approved
    if split_entries.pending_approval.any?
      errors.add(:base, "All participants must approve before locking")
    end
  end

  def generate_verification_token
    loop do
      self.verification_token = SecureRandom.urlsafe_base64(32)
      break unless SplitAgreement.exists?(verification_token: verification_token)
    end
  end

  def set_locked_at
    self.locked_at = Time.current if status == "locked"
  end

  def will_save_change_to_status_to_locked?
    will_save_change_to_status? && status == "locked"
  end
end
