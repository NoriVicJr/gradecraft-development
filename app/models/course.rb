require_relative "role"

class Course < ActiveRecord::Base
  include Copyable
  include UnlockableCondition
  include Analytics::CourseAnalytics

  after_create :create_admin_memberships

  # Note: we are setting the role scopes as instance methods,
  # not class methods, so that they are limited to the users
  # of the current course
  Role.all.each do |role|
    define_method(role.pluralize) do
      User.with_role_in_course(role, self)
    end
  end

  # Staff returns all professors and GSI for the course.
  # Note that this is different from is_staff? which currently
  # includes Admin users
  def staff
    User.with_role_in_course("staff", self)
  end

  def instructors_of_record
    InstructorsOfRecord.for(self).users
  end

  def instructors_of_record_ids
    instructors_of_record.map(&:id)
  end

  def instructors_of_record_ids=(value)
    user_ids = value.map(&:to_i)
    InstructorsOfRecord.for(self).update_course_memberships(user_ids)
  end

  def students_being_graded
    User.students_being_graded_for_course(self)
  end

  def students_being_graded_by_team(team)
    User.students_being_graded_for_course(self, team)
  end

  def students_by_team(team)
    User.students_for_course(self, team)
  end

  with_options dependent: :destroy do |c|
    c.has_many :assignment_types
    c.has_many :assignments
    c.has_many :announcements
    c.has_many :badges
    c.has_many :challenges
    c.has_many :challenge_grades, through: :challenges
    #c.has_many :criteria, through: :rubrics
    #c.has_many :criterion_grades, through: :rubrics
    c.has_many :earned_badges
    c.has_many :flagged_users
    c.has_many :file_uploads
    c.has_many :grade_scheme_elements, -> { extending GradeSchemeElementScoringExtension }
    c.has_many :grades
    c.has_many :groups
    c.has_many :group_memberships
    #c.has_many :levels, through: :assignments
    #c.has_many :level_badges, through: :assignments
    c.has_many :linked_courses, dependent: :destroy
    c.has_many :rubrics
    c.has_many :submissions
    c.has_many :teams
    c.has_many :course_memberships
    c.has_many :submissions_exports
    c.has_many :course_analytics_exports
    c.has_many :events
    c.has_many :providers, as: :providee
    c.has_many :learning_objective_categories
  end

  has_many :users, through: :course_memberships
  belongs_to :institution
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :assignments

  mount_uploader :syllabus, CourseSyllabusUploader

  accepts_nested_attributes_for :grade_scheme_elements, allow_destroy: true

  validates_presence_of :name, :course_number, :student_term, :team_term, :group_term,
    :team_leader_term, :group_term, :weight_term, :badge_term, :assignment_term, :challenge_term, :grade_predictor_term

  validates_numericality_of :total_weights, :max_weights_per_assignment_type,
    :max_assignment_types_weighted, less_than_or_equal_to: 999999999, greater_than: 0, if: lambda { self.has_multipliers? }, message: "must be set to greater than 0 for the Multipliers feature to work properly."

  validates_format_of :twitter_hashtag, with: /\A[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*\z/, allow_blank: true, length: { within: 3..20 }
  validates_format_of :twitter_handle, with: /\A[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*\z/, allow_blank: true, length: { within: 3..20 }
  validates_format_of :phone, with:  /\A^[0-9\+\(]{1,}[0-9\-\.\(\)]{3,15}$\z/, allow_blank: true, message: "must be a valid phone number."

  scope :alphabetical, -> { order("course_number ASC") }
  scope :active, -> { where(status: true) }
  scope :inactive, -> { where.not(status: true) }

  enum learning_objective_term: [ "Learning Objectives", "Learning Goals", "Competencies", "Standards" ]

  def copy(copy_type, attributes={})
    if copy_type != "with_students"
      copy_with_associations(attributes.merge(lti_uid: nil, status: true), [])
    else
      begin
        Course.skip_callback(:create, :after, :create_admin_memberships)
        copy_with_associations(attributes.merge(lti_uid: nil, status: true), [:course_memberships, :teams])
      ensure
        Course.set_callback(:create, :after, :create_admin_memberships)
      end
    end
  end

  def linked?(provider)
    self.linked_courses.where(provider: provider).exists?
  end

  def linked_for(provider)
    self.linked_courses.where(provider: provider).first
  end

  def valuable_badges?
    badges.any? { |badge| badge.full_points.present? && badge.full_points > 0 }
  end

  def formatted_short_name
    if semester.present? && year.present?
      "#{self.course_number} #{(self.semester).capitalize.first[0]}#{self.year}"
    else
      "#{course_number}"
    end
  end

  # total number of points 'available' in the course - the sum of all assignments
  def total_points
    assignments.sum("full_points")
  end

  def point_total_for_challenges
    challenges.pluck("full_points").compact.sum
  end

  def active?
    status == true
  end

  def student_weighted?
    has_multipliers?
  end

  def assignment_weight_open?
    weights_close_at.nil? || weights_close_at > Time.now
  end

  def assignment_weight_for_student(student)
    student.assignment_type_weights.where(course_id: self.id).pluck("weight").sum
  end

  def assignment_weight_spent_for_student(student)
    assignment_weight_for_student(student) >= total_weights.to_i
  end

  def recalculate_student_scores
    ordered_student_ids.each do |student_id|
      ScoreRecalculatorJob.new(user_id: student_id, course_id: self.id).enqueue
    end
  end

  def formatted_long_name
    if semester.present? && year.present?
      "#{self.course_number} #{self.name} #{(self.semester).capitalize} #{self.year}"
    else
      "#{self.name}"
    end
  end

  def searchable_name
    @name || "#{ formatted_long_name} - #{ professor_names}"
  end

  def professor_names
    self.staff.map(&:name)
  end

  def ordered_student_ids
    User
      .joins(:course_memberships)
      .where("course_memberships.course_id = ? and course_memberships.role = ?", self.id, "student")
      .select(:id) # only need the ids, please
      .order("id ASC")
      .collect(&:id)
  end

  # creating a list of students who are taking the class for a grade who do
  # not have any predictions
  def nonpredictors
    nonpredictors = []
    self.students_being_graded.each do |student|
      if student.predictions_for_course?(self) == false
        nonpredictors << student
      end
    end
    return nonpredictors
  end

  private

  def create_admin_memberships
    User.where(admin: true).each do |admin|
      CourseMembership.create course_id: self.id, user_id: admin.id, role: "admin"
    end
  end

  def copy_with_associations(attributes, associations)
    ModelCopier.new(self).copy(attributes: attributes,
                               associations: [
                                 :badges,
                                 { assignment_types: { course_id: :id }},
                                 :challenges,
                                 :grade_scheme_elements
                               ] + associations,
                               options: { prepend: { name: "Copy of "} })
  end
end
