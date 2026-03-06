class Project < ApplicationRecord
  belongs_to :owner, class_name: "User"
  has_many   :collaborations, dependent: :destroy
  has_many   :collaborators, through: :collaborations, source: :user
  has_many   :project_files, dependent: :destroy
  has_one    :split_agreement, dependent: :destroy
  has_many   :split_entries, through: :split_agreement

  enum :visibility, { private_project: 0, public_project: 1 }
  enum :status, { draft: 0, active: 1, completed: 2, archived: 3 }

  validates :title, presence: true, length: { maximum: 100 }
  validates :description, length: { maximum: 1000 }, allow_blank: true
  validates :genre, length: { maximum: 50 }, allow_blank: true
  validates :bpm, numericality: {
    only_integer: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 999
  }, allow_nil: true

  scope :visible_to, ->(user) {
    if user
      left_joins(:collaborations)
        .where(
          "projects.visibility = :public OR projects.owner_id = :uid OR (collaborations.user_id = :uid AND collaborations.status = :accepted)",
          public: visibilities[:public_project],
          uid: user.id,
          accepted: Collaboration.statuses[:accepted]
        ).distinct
    else
      where(visibility: :public_project)
    end
  }

  def owned_by?(user)
    owner_id == user&.id
  end

  def accessible_by?(user)
    public_project? || owned_by?(user) || accepted_collaborator?(user)
  end

  def all_participants
    [owner] + collaborators.merge(collaborations.accepted)
  end

  private

  def accepted_collaborator?(user)
    return false unless user
    collaborations.accepted.exists?(user_id: user.id)
  end
end
