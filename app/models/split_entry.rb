class SplitEntry < ApplicationRecord
  belongs_to :split_agreement
  belongs_to :user

  # Validations
  validates :percentage, presence: true,
    numericality: {
      greater_than: 0,
      less_than_or_equal_to: 100,
      message: "must be between 0 and 100"
    }

  validates :user_id, uniqueness: {
    scope: :split_agreement_id,
    message: "already has a split entry"
  }

  validate :agreement_not_locked
  validate :user_is_project_participant

  # Scopes
  scope :approved, -> { where.not(approved_at: nil) }
  scope :pending_approval, -> { where(approved_at: nil) }

  # Callbacks
  after_update :check_auto_lock, if: :saved_change_to_approved_at?

  # Instance methods
  def approved?
    approved_at.present?
  end

  def approve!(approving_user)
    return false unless can_be_approved_by?(approving_user)
    return false if split_agreement.locked?

    update!(approved_at: Time.current)
  end

  def can_be_approved_by?(user)
    user.id == self.user_id
  end

  private

  def agreement_not_locked
    if split_agreement&.locked? && (new_record? || percentage_changed?)
      errors.add(:base, "Cannot modify locked agreement")
    end
  end

  def user_is_project_participant
    return unless split_agreement&.project

    participant_ids = split_agreement.project.all_participants.pluck(:id)
    unless participant_ids.include?(user_id)
      errors.add(:user, "must be a project participant")
    end
  end

  def check_auto_lock
    split_agreement.auto_lock! if split_agreement.can_lock?
  end
end
