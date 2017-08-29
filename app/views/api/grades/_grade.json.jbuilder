json.type "grades"
json.id   grade.id.to_s

json.attributes do
  json.id                         grade.id
  json.assignment_id              grade.assignment_id
  json.student_id                 grade.student_id
  json.student_name               grade.student.name
  json.group_id                   grade.group_id
  json.feedback                   grade.feedback
  json.complete                   grade.complete
  json.student_visible            grade.student_visible
  json.raw_points                 grade.raw_points
  json.pass_fail_status           grade.pass_fail_status
  json.adjustment_points          grade.adjustment_points
  json.final_points               grade.final_points
  json.adjustment_points_feedback grade.adjustment_points_feedback
  json.updated_at                 grade.updated_at
  json.graded_at                  grade.graded_at
end

json.relationships do
  if grade.file_uploads.present?
    json.file_uploads do
      json.data grade.file_uploads do |file_upload|
        json.type "file_uploads"
        json.id file_upload.id.to_s
      end
    end
  end

  if grade.criterion_grades.present?
    json.criterion_grades do
      json.data grade.criterion_grades do |criterion_grade|
        json.type "criterion_grades"
        json.id criterion_grade.id.to_s
      end
    end
  end

  if grade.learning_objective_outcomes.present?
    json.learning_objective_outcomes do
      json.data grade.learning_objective_outcomes do |outcome|
        json.type "learning_objective_outcomes"
        json.id outcome.id.to_s
      end
    end
  end
end
