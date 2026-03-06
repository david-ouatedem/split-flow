class ProjectFile < ApplicationRecord
  belongs_to :project
  belongs_to :uploader, class_name: "User"

  has_one_attached :file

  # Validations
  validates :name, presence: true
  validates :label, presence: true
  validates :version, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :file, presence: true, on: :create
  validate :file_size_within_limit
  validate :file_content_type_allowed

  # File type whitelist (audio files + common project files)
  ALLOWED_CONTENT_TYPES = %w[
    audio/wav audio/x-wav audio/wave
    audio/mpeg audio/mp3
    audio/flac
    audio/aiff audio/x-aiff
    audio/ogg
    audio/m4a audio/mp4
    application/zip
  ].freeze

  MAX_FILE_SIZE = 200.megabytes

  # Scopes
  scope :by_label, ->(label) { where(label: label) }
  scope :latest_versions, -> { select("DISTINCT ON (project_id, label) *").order(:project_id, :label, version: :desc) }
  scope :ordered, -> { order(created_at: :desc) }

  # Callbacks
  before_validation :set_version, on: :create
  before_validation :set_name_from_file, if: -> { file.attached? && name.blank? }

  private

  def set_version
    return if version.present?

    last_version = project.project_files.by_label(label).maximum(:version) || 0
    self.version = last_version + 1
  end

  def set_name_from_file
    self.name = file.filename.to_s if file.attached?
  end

  def file_size_within_limit
    return unless file.attached?

    if file.byte_size > MAX_FILE_SIZE
      errors.add(:file, "is too large (maximum is #{MAX_FILE_SIZE / 1.megabyte}MB)")
    end
  end

  def file_content_type_allowed
    return unless file.attached?

    unless ALLOWED_CONTENT_TYPES.include?(file.content_type)
      errors.add(:file, "must be an audio file (WAV, MP3, FLAC, AIFF, OGG, M4A) or ZIP")
    end
  end
end
