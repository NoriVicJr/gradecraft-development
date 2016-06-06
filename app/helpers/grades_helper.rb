module GradesHelper
  extend SubmissionsHelper

  def grading_status_count_for(course)
    unreleased_grades_count_for(course) +
      in_progress_grades_count_for(course) +
      no_status_grades_count_for(course) +
      ungraded_submissions_count_for(course) +
      resubmission_count_for(course)
  end

  def in_progress_grades_count_for(course)
    Rails.cache.fetch(in_progress_grades_count_cache_key(course)) do
      course.grades.in_progress.count
    end
  end

  def in_progress_grades_count_cache_key(course)
    # This cache key is busted when a grade is updated
    "#{course.cache_key}/in_progress_grades_count"
  end

  def no_status_grades_count_for(course)
    Rails.cache.fetch(no_status_grades_count_cache_key(course)) do
      course.grades.no_status.count
    end
  end

  def no_status_grades_count_cache_key(course)
    # This cache key is busted when a grade is updated
    "#{course.cache_key}/no_status_grades_count"
  end

  def unreleased_grades_count_for(course)
    Rails.cache.fetch(unreleased_grades_count_cache_key(course)) do
      course.grades.not_released.count
    end
  end

  def unreleased_grades_count_cache_key(course)
    # This cache key is busted when a grade is updated
    "#{course.cache_key}/unreleased_grades_count"
  end

  def initial_grade_json(grade)
    JbuilderTemplate.new(ApplicationController.new.view_context).encode do |json|
      json.grade do
        json.partial! "grades/grade", grade: grade, assignment: grade.assignment
      end

      json.badges do
        json.partial! "grades/badges", badges: grade.student.earnable_course_badges_for_grade(grade), student_id: grade.student_id
      end

      json.assignment do
        json.partial! "grades/assignment", assignment: grade.assignment
      end

      json.assignment_score_levels do
        json.partial! "grades/assignment_score_levels", assignment_score_levels: grade.assignment.assignment_score_levels.order_by_value
      end
    end.to_json
  end
end
