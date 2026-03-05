class Collaboration < ApplicationRecord
  belongs_to :user
  belongs_to :project

  enum :status, { pending: 0, accepted: 1, declined: 2 }

  validates :user_id, uniqueness: { scope: :project_id, message: "is already a collaborator" }
  validates :role, length: { maximum: 50 }, allow_blank: true
  validate  :cannot_invite_owner

  scope :for_user, ->(user) { where(user_id: user.id) }

  private

  def cannot_invite_owner
    errors.add(:user, "cannot be invited to their own project") if user_id == project&.owner_id
  end
end
