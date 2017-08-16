json.type "assignments"
json.id assignment.id.to_s
json.attributes do

  json.accepts_attachments          assignment.accepts_attachments
  json.accepts_links                assignment.accepts_links
  json.accepts_submissions_until    assignment.accepts_submissions_until
  json.accepts_text                 assignment.accepts_text
  json.assignment_type_id           assignment.assignment_type_id
  json.description                  assignment.description
  json.due_at                       assignment.due_at
  json.full_points                  assignment.full_points
  json.grade_scope                  assignment.grade_scope
  json.id                           assignment.id
  json.media                        assignment.media.url
  json.min_group_size               assignment.min_group_size
  json.max_group_size               assignment.max_group_size
  json.name                         assignment.name
  json.open_at                      assignment.open_at
  json.pass_fail                    assignment.pass_fail
  json.position                     assignment.position
  json.purpose                      assignment.purpose
  json.release_necessary            assignment.release_necessary
  json.show_name_when_locked        assignment.show_name_when_locked
  json.show_points_when_locked      assignment.show_points_when_locked
  json.show_description_when_locked assignment.show_description_when_locked
  json.show_purpose_when_locked     assignment.show_purpose_when_locked
  json.resubmissions_allowed        assignment.resubmissions_allowed
  json.threshold_points             assignment.threshold_points
  json.updated_at                   assignment.updated_at
  json.visible_when_locked          assignment.visible_when_locked
  json.has_submitted_submissions    assignment.has_submitted_submissions?
  json.learning_objective_id        assignment.learning_objective_id

  # boolean attributes
  json.visible                    assignment.visible
  json.required                   assignment.required
  json.accepts_submissions        assignment.accepts_submissions
  json.student_logged             assignment.student_logged

  # boolean flags (for predictor logic)

  json.has_info             !assignment.description.blank?
  json.has_levels           assignment.assignment_score_levels.present?
  json.has_threshold        assignment.threshold_points && assignment.threshold_points > 0
  json.is_a_condition       assignment.is_a_condition?
  json.is_due_in_future     assignment.due_at.present? && assignment.due_at >= Time.now
  json.is_earned_by_group   assignment.grade_scope == "Group"
  json.is_required          assignment.required
  json.is_rubric_graded     assignment.grade_with_rubric?
  json.is_visible           assignment.visible?

  if @student.present?
    json.has_been_unlocked \
      assignment.is_unlockable? && assignment.is_unlocked_for_student?(@student)

    json.has_submission \
      assignment.accepts_submissions? &&
      @student.submission_for_assignment(assignment).present?

    json.is_accepting_submissions \
      assignment.accepts_submissions? &&
      !assignment.submissions_have_closed? &&
      !@student.submission_for_assignment(assignment).present?

    json.is_late \
      assignment.overdue? && assignment.accepts_submissions &&
      !@student.submission_for_assignment(assignment).present?

    json.is_closed_without_submission \
      assignment.submissions_have_closed? &&
      !@student.submission_for_assignment(assignment).present?

    json.is_locked !assignment.is_unlocked_for_student?(@student)

  # booleans for generic predictor
  else
    json.is_locked false
    json.has_been_unlocked false
    json.has_submission false
    json.is_accepting_submissions \
      assignment.accepts_submissions? && !assignment.submissions_have_closed?
    json.is_late \
      assignment.overdue? && assignment.accepts_submissions
    json.is_closed_without_submission false
  end

  # Assignment Score Levels

  if assignment.assignment_score_levels.present?
    json.score_levels assignment.assignment_score_levels do |asl|
      json.id asl.id
      json.name asl.name
      json.points asl.points
    end
  end

  # conditions and keys

  if assignment.unlock_conditions.present?

    unlock_conditions = assignment.unlock_conditions.map do |condition|
      condition.requirements_description_sentence
    end
    json.unlock_conditions unlock_conditions

    unlocked_conditions = assignment.unlock_conditions.map do |condition|
      condition.requirements_completed_sentence
    end
    json.unlocked_conditions unlocked_conditions

    # used in predictor front end to determine if any conditions are closed
    json.conditional_assignment_ids assignment.unlock_conditions.where(condition_type: "Assignment").pluck(:condition_id)
  end

  if assignment.unlock_keys.present?
    unlock_keys = assignment.unlock_keys.map do |key|
      key.key_description_sentence
    end
    json.unlock_keys unlock_keys
  end
end

json.relationships do
  if assignment.assignment_files.present?
    json.file_uploads do
      json.data assignment.assignment_files do |assignment_file|
        json.type "file_uploads"
        json.id assignment_file.id.to_s
      end
    end
  end

  if @predicted_earned_grades.present? && @predicted_earned_grades.where(assignment_id: assignment.id).present?
    json.prediction data: {
      type: "predicted_earned_grades",
      id: @predicted_earned_grades.where(assignment_id: assignment.id).first.id.to_s
    }
  end

  if @grades.present? && @grades.where(assignment_id: assignment.id).present?
    grade =  @grades.where(assignment_id: assignment.id).first
    if GradeProctor.new(grade).viewable?(@student)
      json.grade data: { type: "grades", id: grade.id.to_s }
    end
  end

  if assignment.grade_with_rubric?
    json.rubric do
      json.data type: "rubrics", id: assignment.rubric.id.to_s
      json.links related: api_rubric_path(assignment.rubric.id)
    end
  end
end
