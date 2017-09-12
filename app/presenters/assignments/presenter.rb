require "active_support/inflector"
require "./lib/showtime"
require_relative "../submissions/grade_history"
require_relative "../../models/history_filter"

class Assignments::Presenter < Showtime::Presenter
  include Showtime::ViewContext
  include Submissions::GradeHistory

  def assignment
    properties[:assignment]
  end

  def assignment_type
    assignment.assignment_type
  end

  def submission_for_assignment(student)
    @submission ||= student.submission_for_assignment(assignment, false)
  end

  def course
    properties[:course]
  end

  def for_team?
    properties.key?(:team_id) && !team.nil?
  end

  def grade_for_student(student)
    grades.where(student_id: student.id).first ||
      Grade.new(assignment_id: assignment.id)
  end

  def prediction(assignment, student)
    assignment.predicted_earned_grades.where(student: student).first
  end

  def positive_prediction_for?(assignment, student)
    prediction = prediction(assignment, student)
    return true if prediction.present? && prediction.predicted_points > 0
  end

  def grades
    assignment.grades
  end

  def grades_available_for?(user)
    user.grade_visible_for_assignment?(assignment)
  end

  def groups
    Assignments::GroupPresenter.wrap(assignment.groups.order_by_name, :group, { assignment: assignment })
  end

  def group_assignment?
    assignment.has_groups?
  end

  def group_for(student)
    student.group_for_assignment(assignment)
  end

  def group_submission_for(student)
    group_for(student).submission_for_assignment(assignment)
  end

  def has_grades?
    grades.present?
  end

  def has_persisted_grades?
    grades.instructor_modified.any?(&:persisted?)
  end

  def has_reviewable_grades?
    grades.instructor_modified.present?
  end

  def has_viewable_submission?(student, user)
    submission = student.submission_for_assignment(assignment, submitted_only=false)
    assignment.accepts_submissions? &&
      submission.present? &&
      SubmissionProctor.new(submission).viewable?(user)
  end

  def has_viewable_analytics?(user)
    AnalyticsProctor.new.viewable?(user, course) && !assignment.hide_analytics?
  end

  def has_teams?
    course.has_teams?
  end

  def assignment_has_viewable_description?(user)
    (assignment.description.present? || assignment.assignment_files.present?) &&
    ( user.is_staff?(course) ||
      assignment.description_visible_for_student?(user)
    )
  end

  def assignment_has_viewable_purpose?(user)
    assignment.purpose.present? &&
    ( user.is_staff?(course) ||
      assignment.purpose_visible_for_student?(user)
    )
  end

  def assignment_accepting_submissions?(student)
    student.present? &&
    assignment.accepts_submissions? &&
    !assignment.submissions_have_closed? &&
    ( assignment.is_unlocked_for_student?(student) ||
      ( assignment.has_groups? &&
        assignment.is_unlocked_for_group?(
          student.group_for_assignment(assignment))
      )
    )
  end

  def individual_assignment?
    assignment.is_individual?
  end

  def submission_submitted_date_for(submission)
    submission.submitted_at if submission
  end

  def submission_resubmitted?(submission)
    submission.nil? ? false : submission.resubmitted?
  end

  def new_assignment?
    !assignment.persisted?
  end

  def rubric
    assignment.find_or_create_rubric
  end

  def grade_with_rubric?
    assignment.grade_with_rubric?
  end

  # show the rubric preview tab on student's view
  def show_rubric_preview?(user)
    grade_with_rubric? && !grades_available_for?(user) && ( !user || assignment.description_visible_for_student?(user) )
  end

  def student_logged?(user)
    assignment.student_logged? && assignment.open? && user.is_student?(course)
  end

  def submission_grade_history(student)
    grade = self.grade_for_student(student)
    submission = self.submission_for_assignment(student)
    submission_grade_filtered_history(submission, grade)
  end

  def teams
    course.teams
  end

  def team
    @team ||= teams.find_by(id: properties[:team_id])
  end

  def students
    @students ||= AssignmentStudentCollection.new(User
      .active_students_for_course(course, team)
      .order_by_name, self)
  end

  def has_viewable_learning_objectives?(current_student)
    course.has_learning_objectives? && (course.always_show_objectives? ||
      grade_for_student(current_student).assignment.learning_objectives.any?)
  end

  class AssignmentStudentCollection
    include Enumerable

    attr_reader :presenter

    def initialize(students, presenter)
      @students = students
      @presenter = presenter
    end

    def each
      @students.each { |student| yield AssignmentStudentDecorator.new(student, presenter) }
    end
  end

  class AssignmentStudentDecorator < SimpleDelegator
    attr_reader :presenter

    def initialize(student, presenter)
      @presenter = presenter
      super student
    end
  end
end
