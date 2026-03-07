class User < ApplicationRecord
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_one_attached :avatar

  has_many :owned_projects, class_name: "Project", foreign_key: :owner_id, dependent: :destroy
  has_many :collaborations, dependent: :destroy
  has_many :collaborated_projects, through: :collaborations, source: :project
  has_many :uploaded_files, class_name: "ProjectFile", foreign_key: :uploader_id, dependent: :destroy
  has_many :split_entries, dependent: :restrict_with_error
  has_many :split_agreements, through: :split_entries

  enum :role, {
    producer:   0,
    beatmaker:  1,
    mixer:      2,
    artist:     3,
    vocalist:   4,
    songwriter: 5
  }

  ALLOWED_SKILLS = %w[
    Drums Melody Mixing Mastering Vocals Arrangement
    Sampling Synthesis SoundDesign Composition Lyrics
  ].freeze

  ALLOWED_PLATFORMS = %w[soundcloud spotify youtube bandcamp beatstars].freeze

  validates :display_name, length: { maximum: 50 }, allow_blank: true
  validates :bio, length: { maximum: 500 }, allow_blank: true
  validates :role, inclusion: { in: roles.keys }, allow_nil: true
  before_validation :clean_skills

  validate  :validate_skills_entries
  validate  :validate_portfolio_urls_format

  private

  def clean_skills
    self.skills = skills.reject(&:blank?) if skills.present?
  end

  def validate_skills_entries
    return if skills.blank?
    invalid = skills - ALLOWED_SKILLS
    errors.add(:skills, "contains invalid entries: #{invalid.join(', ')}") if invalid.any?
  end

  def validate_portfolio_urls_format
    return if portfolio_urls.blank?
    portfolio_urls.each do |platform, url|
      unless ALLOWED_PLATFORMS.include?(platform.to_s)
        errors.add(:portfolio_urls, "contains unknown platform: #{platform}")
      end
      unless url.to_s.match?(%r{\Ahttps?://}i)
        errors.add(:portfolio_urls, "#{platform} URL must start with http:// or https://")
      end
    end
  end
end
