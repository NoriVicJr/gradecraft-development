class CourseMembership < ActiveRecord::Base
  belongs_to :course, touch: true
  belongs_to :user, touch: true, inverse_of: :course_memberships
  belongs_to :grade_scheme_element, foreign_key: "earned_grade_scheme_element_id"

  # adds logging helpers for rescued-out errors
  include ModelAddons::ImprovedLogging
  include ModelAddons::AdvancedRescue
  include Copyable

  Role.all.each do |role|
    scope role.pluralize, ->(course) { where role: role }
    define_method("#{role}?") do
      self.role == role
    end
  end

  scope :auditing, -> { where( role: "student", auditing: true, active: true ) }
  scope :being_graded, -> { where( role: "student", auditing: false, active: true) }
  scope :instructors_of_record, -> { where(instructor_of_record: true) }
  # scope to help guide emails to people (both students and staff) who are participating in the class, but not admins
  scope :participants, -> { where.not(role: "admin") }
  scope :active, -> { where(active: true) }

  validates_presence_of :course, :user, :role

  validates :instructor_of_record, instructor_of_record: true

  after_save :check_unlockables

  def self.create_or_update_from_lti(student, course, auth_hash)
    return false unless auth_hash["extra"] && auth_hash["extra"]["raw_info"] && auth_hash["extra"]["raw_info"]["roles"]
    course_membership = student.course_memberships.find_or_initialize_by(course_id: course.id)

    auth_hash["extra"]["raw_info"].tap do |extra|
      case extra["roles"].downcase
      when /instructor/
        course_membership.role = "professor"
      when /teachingassistant/
        course_membership.role = "gsi"
      when /learner/
        course_membership.role = "student"
        course_membership.instructor_of_record = false
      else
        course_membership.role = "observer"
        course_membership.instructor_of_record = false
      end
    end
    course_membership.last_login_at = DateTime.now
    course_membership.save
  end

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(attributes: attributes.merge(score: 0))
  end

  def recalculate_and_update_student_score
    update_attribute :score, recalculated_student_score
  end

  def recalculated_student_score
    assignment_type_totals_for_student +
    student_earned_badge_score +
    conditional_student_team_score
  end

  def check_and_update_student_earned_level
    course.grade_scheme_elements.with_lowest_points.order_by_points_asc.map { |gse| gse.unlock!(user) }
    update_attributes earned_grade_scheme_element_id: earned_grade_scheme_element.try(:id)
  end

  def earned_grade_scheme_element(grade_scheme_elements=nil)
    elements = grade_scheme_elements || course.grade_scheme_elements.with_lowest_points.order_by_points_asc
    element_earned = nil

    elements.sort_by{ |element| element.lowest_points }.each_with_index do |gse, index|
      element_earned = gse if index == 0

      break if !gse.is_unlocked_for_student?(user)

      if gse.lowest_points <= score
        element_earned = gse
      end
    end

    element_earned
  end

  def staff?
    professor? || gsi? || admin?
  end

  def check_unlockables
    if self.course.is_a_condition?
      self.course.unlock_keys.map(&:unlockable).each do |unlockable|
        unlockable.unlock!(user)
      end
    end
  end

  private

  def assignment_type_totals_for_student
    rescue_with_logging 0 do
      course.assignment_types.collect do |assignment_type|
        assignment_type.visible_score_for_student(user)
      end.compact.sum || 0
    end
  end

  def student_earned_badge_score
    rescue_with_logging 0 do
      user.earned_badge_score_for_course(course_id) || 0
    end
  end

  def conditional_student_team_score
    include_team_score? ? student_team_score : 0
  end

  def student_team_score
    rescue_with_logging 0 do
      user.team_for_course(course_id).try(:score) || 0
    end
  end

  def include_team_score?
    course.add_team_score_to_student? && !course.team_score_average
  end
end
