class Badge < ActiveRecord::Base
  include Copyable
  include UnlockableCondition
  include MultipleFileAttributes
  include Analytics::BadgeAnalytics
  include S3Manager::Copying

  acts_as_list scope: :course

  mount_uploader :icon, BadgeIconUploader

  has_many :earned_badges, dependent: :destroy
  has_many :predicted_earned_badges, dependent: :destroy

  belongs_to :course

  accepts_nested_attributes_for :earned_badges, allow_destroy: true, reject_if: proc { |a| a.points.blank? }

  multiple_files :badge_files
  has_many :badge_files, dependent: :destroy, inverse_of: :badge
  accepts_nested_attributes_for :badge_files

  validates_presence_of :course, :name
  validates_numericality_of :full_points, allow_nil: true, length: { maximum: 9 }
  validates_inclusion_of :visible, :can_earn_multiple_times, :visible_when_locked,
    :show_name_when_locked, :show_points_when_locked, :show_description_when_locked,
    in: [true, false], message: "must be true or false"

  scope :visible, -> { where(visible: true) }
  scope :ordered, -> { order("position ASC") }
  scope :earned_this_week, -> { includes(:earned_badges).where("earned_badges.updated_at > ?", 7.days.ago).references(:earned_badges) }

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes.merge(icon: nil, remove_icon: true),
      options: {
        lookups: [:courses],
        overrides: [
          -> (copy) { copy_files copy }
        ]
      }
    )
  end

  # Counting how many times a particular student has earned this badge
  def earned_badge_count_for_student(student)
    earned_badges.where(student_id: student.id, student_visible: true).count
  end

  # Can this badge be awarded to a student?
  # Must accound for invisible earned badges
  def available_for_student?(student)
    can_earn_multiple_times ||
    earned_badges.where(student_id: student.id).count < 1
  end

  private

  # Copy files that are stored on S3 via Carrierwave
  def copy_files(copy)
    copy.save unless copy.persisted?
    copy_icon(copy) if icon.present?
    copy_badge_files(copy) if badge_files.any?
  end

  # Copy badge icon
  def copy_icon(copy)
    remote_upload(copy, self, "icon", icon.url)
  end

  # Copy badge files
  def copy_badge_files(copy)
    badge_files.each do |bf|
      next unless exists_remotely?(bf, "file")
      badge_file = copy.badge_files.create filename: bf[:filename]
      remote_upload(badge_file, bf, "file", bf.url)
    end
  end
end
