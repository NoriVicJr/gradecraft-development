class Assignment < ActiveRecord::Base
  include Copyable
  include Gradable
  include MultipleFileAttributes
  include Sanitizable
  include ScoreLevelable
  include UploadsMedia
  include UnlockableCondition
  include Analytics::AssignmentAnalytics

  belongs_to :course
  belongs_to :assignment_type, -> { order("position ASC") }

  has_one :rubric, dependent: :destroy
  # has_many :criteria, through: :rubric
  # has_many :levels, through: :criteria
  # has_many :level_badges, through: :criteria
  has_many :criterion_grades, dependent: :destroy

  multiple_files :assignment_files
  # Preventing malicious content from being submitted
  # clean_html :description
  clean_html :purpose

  # For instances where the assignment needs its own unique score levels
  score_levels :assignment_score_levels, -> { order "points" }, dependent: :destroy

  # Student created groups, can connect to multiple assignments and receive
  # group level or individualized feedback
  has_many :assignment_groups, dependent: :destroy
  has_many :groups, through: :assignment_groups

  # Student created submissions to be graded
  has_many :submissions, dependent: :destroy

  has_many :learning_objective_links, as: :learning_objective_linkable, dependent: :destroy
  has_many :learning_objectives, through: :learning_objective_links

  has_one :imported_assignment, dependent: :destroy

  # Instructor uploaded resource files
  has_many :assignment_files, dependent: :destroy, inverse_of: :assignment
  accepts_nested_attributes_for :assignment_files

  # Strip points from pass/fail assignments
  before_save :zero_points_for_pass_fail
  before_save :reset_default_for_nil_values

  validates_presence_of :name, :course_id, :assignment_type_id, :grade_scope, :threshold_points

  validates_inclusion_of :student_logged, :required, :accepts_submissions,
  :visible, :resubmissions_allowed, :use_rubric, :accepts_attachments,
  :accepts_text, :accepts_links, :pass_fail, :hide_analytics, :visible_when_locked,
  :show_name_when_locked, :show_points_when_locked, :show_description_when_locked,
  :show_purpose_when_locked, in: [true, false], message: "must be true or false"

  validates_numericality_of :max_group_size, :min_group_size, allow_nil: true, greater_than_or_equal_to: 1
  validates_with OpenBeforeCloseValidator
  validates_with SubmissionsAcceptedAfterOpenValidator
  validates_with SubmissionsAcceptedAfterDueValidator
  validates_with PointsUnderCapValidator
  validates_with MaxOverMinValidator

  scope :group_assignments, -> { where grade_scope: "Group" }

  # Sorting assignments by different properties
  scope :chronological, -> { order("due_at ASC") }
  scope :alphabetical, -> { order("name ASC") }
  scope :ordered, -> { order("position ASC") }
  acts_as_list scope: :assignment_type

  # Filtering Assignments by various date properties
  scope :with_dates, -> { where("assignments.due_at IS NOT NULL OR assignments.open_at IS NOT NULL") }

  delegate :student_weightable?, to: :assignment_type

  # Default method triggered by ModelCopier + ModelAssociationCopier
  # Primarily used when copying on a higher level; i.e. copying an entire course
  def copy(attributes={})
    copy_with_associations attributes, {
      overrides: [
        -> (copy) { copy.rubric = self.rubric.copy if self.rubric.present? },
        -> (copy) { copy.rubric.course_id = copy.course_id if self.rubric.present? },
      ]
    }
  end

  # Copy a specific assignment while prepending 'Copy of' to the name
  def copy_with_prepended_name(attributes={})
    copy_with_associations attributes, {
      prepend: { name: "Copy of " },
      overrides: [
        -> (copy) { copy.rubric = self.rubric.copy if self.rubric.present? },
        -> (copy) { copy.rubric.course_id = copy.course_id if self.rubric.present? },
      ]
    }
  end

  def to_json(options = {})
    super(options.merge(only: [:id]))
  end

  def full_points
    super.presence || 0
  end

  def grade_with_rubric?
    use_rubric && rubric.present? && rubric.designed?
  end

  def find_or_create_rubric
    return rubric if rubric
    Rubric.create assignment_id: self.id, course_id: self.course_id
  end

  # Checking to see if an assignment is individually graded
  def is_individual?
    !["Group"].include? grade_scope
  end

  # Checking to see if the assignment is a group assignment
  def has_groups?
    grade_scope=="Group"
  end

  def has_submitted_submissions?
    submissions.submitted.any?
  end

  # Custom point total if the class has weighted assignments
  def full_points_for_student(student)
    return 0 unless full_points
    full_points * assignment_type.weight_for_student(student)
  end

  # Checking to see if an assignment is due soon
  def soon?
    future? && due_at < 7.days.from_now
  end

  def student_submissions_with_files
    Submission
      .includes(:submission_files)
      .includes(:student)
      .where(assignment_id: self[:id])
      .where(submissions_with_files_query)
      .to_a # eager-load
  end

  def student_submissions_with_files_for_team(team)
    Submission
      .includes(:submission_files)
      .includes(:student)
      .where(assignment_id: self[:id])
      .where("student_id in (select distinct(student_id) from team_memberships where team_id = ?)", team.id)
      .where(submissions_with_files_query)
      .to_a # eager-load
  end

  def student_with_submissions_query
    "select distinct(student_id) from submissions where assignment_id = ?"
  end

  def group_with_submissions_query
    "select distinct(group_id) from submissions where assignment_id = ?"
  end

  def submissions_with_files_query
    "text_comment <> '' or link <> '' or id in (#{present_submission_files_query})"
  end

  def present_submission_files_query
    "select distinct(submission_id) from submission_files where file_missing is null or file_missing = 'f'"
  end

  def missing_submission_files_query
    "select distinct(submission_id) from submission_files where file_missing = ?"
  end

  # #students_with_submissions methods

  def students_with_submissions
    User.order_by_name
      .where("id in (#{student_with_submissions_query})", self.id)
  end

  def students_with_submissions_on_team(team)
    User.order_by_name
      .where(students_with_submissions_on_team_conditions.join(" AND "), self[:id], team.id)
  end

  def groups_with_files
    Group.order_by_name
      .where("id in (#{group_with_submissions_query} and (#{submissions_with_files_query}))", self.id)
  end

  def students_with_text_or_binary_files
    User.order_by_name
      .where("id in (#{student_with_submissions_query} and (#{submissions_with_files_query}))", self.id)
  end

  def students_with_text_or_binary_files_on_team(team)
    User.order_by_name
      .where("id in (#{student_with_submissions_query} and (#{submissions_with_files_query}))", self.id)
      .where("id in (select distinct(student_id) from team_memberships where team_id = ?)", team.id)
  end

  # students and submissions with missing binaries
  def submitters_with_missing_binaries
    if has_groups?
      submitter_class = Group
      submitter_foreign_key = "group_id"
    else
      submitter_class = User
      submitter_foreign_key = "student_id"
    end

    missing_binaries_query = "id in (select distinct(#{submitter_foreign_key})" \
      "from submissions where assignment_id = ? " \
      "and id in (#{missing_submission_files_query}))"

    submitter_class.order_by_name.where(missing_binaries_query, self.id, true)
  end

  # students and submissions with missing binaries
  def students_with_missing_binaries_on_team(team)
    User.order_by_name
      .where("id in (select distinct(student_id) from submissions where assignment_id = ? and id in (#{missing_submission_files_query}))", self.id, true)
      .where("id in (select distinct(student_id) from team_memberships where team_id = ?)", team.id)
  end

  def submission_files_with_missing_binaries
    SubmissionFile.order("created_at ASC")
      .where(file_missing: true)
      .where("submission_id in (select id from submissions where assignment_id = ?)", self.id)
  end

  def submission_files_with_missing_binaries_for_team(team)
    SubmissionFile.order("created_at ASC")
      .where(file_missing: true)
      .where("submission_id in (select id from submissions where assignment_id = ?)", self.id)
      .where("submission_id in (select id from submissions where student_id in (select distinct(student_id) from team_memberships where team_id = ?))", team.id)
  end

  def has_levels?
    assignment_score_levels.present?
  end

  # Finding what grade level was earned for a particular assignment
  def grade_level(grade)
    assignment_score_levels.find { |asl| grade.final_points == asl.points }.try(:name)
  end

  def future?
    !due_at.nil? && due_at >= Time.now
  end

  def opened?
    open_at.nil? || open_at < Time.now
  end

  def overdue?
    !due_at.nil? && due_at < Time.now
  end

  def accepting_submissions?
    accepts_submissions_until.nil? || accepts_submissions_until > Time.now
  end

  # No longer accepting submissions.
  def submissions_have_closed?
    !accepts_submissions_until.nil? && accepts_submissions_until < Time.now
  end

  # TODO: We need a closed? (or has_closed?) method for assignments with
  # or without submissions

  # Checking to see if the assignment is still open and accepting submissons
  def open?
    opened? && (!overdue? || accepting_submissions?)
  end

  def grade_import(students, options = {})
    GradeExporter.new.export_grades(self, students, options)
  end

  private

  def students_with_submissions_on_team_conditions
    ["id in (#{student_with_submissions_query})",
     "id in (select distinct(student_id) from team_memberships where team_id = ?)"]
  end

  def zero_points_for_pass_fail
    self.full_points = 0 if self.pass_fail?
    self.threshold_points = 0 if self.pass_fail?
  end

  def reset_default_for_nil_values
    self.threshold_points = 0 if self.threshold_points.nil?
  end

  def copy_with_associations(attributes, options)
    ModelCopier.new(self).copy(
      options: options,
      attributes: attributes,
      associations: [
        :assignment_score_levels,
        { assignment_files: { assignment_id: :id }}
      ]
    )
  end
end
