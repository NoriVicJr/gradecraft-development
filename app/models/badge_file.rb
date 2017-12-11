class BadgeFile < ActiveRecord::Base
  include S3Manager::Carrierwave

  belongs_to :badge, inverse_of: :badge_files

  mount_uploader :file, AttachmentUploader
  process_in_background :file

  validates_presence_of :file
  validates :filename, presence: true, length: { maximum: 50 }

  def course
    badge.course
  end
end
