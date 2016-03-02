# TODO: Refactor this to just spawn a bunch of individual GradeUpdatePerformer jobs
class MultipleGradeUpdatePerformer < ResqueJob::Performer
  def setup
    @grade_ids = @attrs[:grade_ids]
    @grades = fetch_grades_with_assignment
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    @grades.each do |grade|
      require_save_scores_success(grade)
      require_notify_released_success(grade)
    end
  end

  protected

  def require_save_scores_success(grade)
    require_success(save_scores_messages(grade)) do
      grade.cache_student_and_team_scores
    end
  end

  def require_notify_released_success(grade)
    if grade.assignment.notify_released? && grade.is_student_visible?
      require_success(notify_released_messages(grade), max_result_size: 200) { notify_grade_released(grade) }
    end
  end

  def save_scores_messages(grade)
    {
      success: "Student and team scores saved successfully for grade ##{grade.id}",
      failure: "Student and team scores failed to save for grade ##{grade.id}"
    }
  end

  def notify_released_messages(grade)
    {
      success: "Successfully sent notification for release of grade ##{grade.id}.",
      failure: "Failed to send grade release notification for grade ##{grade.id}."
    }
  end

  def fetch_grades_with_assignment
    Grade.where(id: @grade_ids).includes(:assignment).load
  end

  def notify_grade_released(grade)
    NotificationMailer.grade_released(grade.id).deliver_now
  end
end
