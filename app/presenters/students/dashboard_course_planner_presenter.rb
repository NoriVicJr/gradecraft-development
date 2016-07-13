require "./lib/showtime"

class Students::DashboardCoursePlannerPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def assignments
    properties[:assignments]
  end

  def to_do?(assignment)
    assignment.include_in_to_do? && assignment.visible_for_student?(student)
  end

  def to_do_assignments
    assignments.select{ |assignment| to_do?(assignment) }
  end

  def course_planner?(assignment)
    to_do?(assignment) && assignment.soon?
  end

  def course_planner_assignments
    assignments.select{ |assignment| course_planner?(assignment) }
  end

  def my_planner?(assignment)
    to_do?(assignment) && starred?(assignment)
  end

  def my_planner_assignments
    assignments.select{ |assignment| my_planner?(assignment) }
  end

  def submittable?(assignment)
    assignment.accepts_submissions? && assignment.is_unlocked_for_student?(student)
  end

  def starred?(assignment)
    assignment.is_predicted_by_student?(student)
  end

  def submitted?(assignment)
    student.submission_for_assignment(assignment).present?
  end

  def due_dates?
    assignments.any?{ |assignment| assignment.due_at? }
  end
end