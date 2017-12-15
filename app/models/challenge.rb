class Challenge < ActiveRecord::Base
  include Copyable
  include ScoreLevelable
  include UploadsMedia
  include MultipleFileAttributes
  include S3Manager::Copying

  # grade points available to the predictor from the assignment controller
  attr_accessor :prediction, :grade

  belongs_to :course
  has_many :submissions
  has_many :challenge_grades, dependent: :destroy do
    def find_or_initialize_for_team(team)
      where(team_id: team.id).first || new(team: team)
    end
  end

  accepts_nested_attributes_for :challenge_grades

  has_many :predicted_earned_challenges, dependent: :destroy

  score_levels :challenge_score_levels

  multiple_files :challenge_files
  has_many :challenge_files, dependent: :destroy, inverse_of: :challenge
  accepts_nested_attributes_for :challenge_files

  scope :with_dates, -> { where("challenges.due_at IS NOT NULL OR challenges.open_at IS NOT NULL") }
  scope :visible, -> { where visible: TRUE }
  scope :chronological, -> { order("due_at ASC") }
  scope :alphabetical, -> { order("name ASC") }

  validates_presence_of :course, :name
  validates_numericality_of :full_points, allow_nil: true, length: { maximum: 9 }
  validates_inclusion_of :visible, :accepts_submissions,
  in: [true, false], message: "must be true or false"

  validates_with PositivePointsValidator, attributes: [:full_points], allow_nil: true
  validates_with OpenBeforeCloseValidator, attributes: [:due_at, :open_at]

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      options: {
        overrides: [-> (copy) { copy_files copy }]
      }
    )
  end

  def has_levels?
    challenge_score_levels.present?
  end

  def challenge_grade_for_team(team)
    challenge_grades.where(team_id: team.id).first
  end

  def future?
    !due_at.nil? && due_at >= Date.today
  end

  # Finding what challenge grade level was earned for a particular challenge
  def challenge_grade_level(challenge_grade)
    challenge_score_levels.find { |csl| challenge_grade.final_points == csl.points }.try(:name)
  end

  private

  def copy_files(copy)
    copy.save unless copy.persisted?
    copy_media(copy) if media.present?
    copy_challenge_files(copy) if challenge_files.any?
  end

  # Copy assignment media
  def copy_media(copy)
    copy.update(media: nil, remove_media: true)
    remote_upload(copy, self, "media", media.url)
  end

  # Copy assignment files
  def copy_challenge_files(copy)
    challenge_files.each do |cf|
      next unless exists_remotely?(cf, "file")
      challenge_file = copy.challenge_files.create filename: cf[:filename]
      remote_upload(challenge_file, cf, "file", cf.url)
    end
  end
end
