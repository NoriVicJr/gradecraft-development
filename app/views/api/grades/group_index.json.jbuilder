json.data @grades do |grade|
  json.partial! 'api/grades/grade', grade: grade
end

json.included do
  if @file_uploads.present?
    json.array! @file_uploads do |file_upload|
      json.type "file_uploads"
      json.id file_upload.id.to_s
      json.attributes do
        json.id file_upload.id
        json.grade_id file_upload.grade_id
        json.filename file_upload.filename
        json.filepath file_upload.filepath
      end
    end
  end

  if @criterion_grades.present?
    json.array! @criterion_grades do |criterion_grade|
      json.type "criterion_grades"
      json.id criterion_grade.id.to_s
      json.attributes do
        json.id             criterion_grade.id
        json.grade_id       criterion_grade.grade_id
        json.assignment_id  criterion_grade.assignment_id
        json.points         criterion_grade.points
        json.criterion_id   criterion_grade.criterion_id
        json.level_id       criterion_grade.level_id
        json.student_id     criterion_grade.student_id
        json.comments       criterion_grade.comments
      end
    end
  end

  outcomes = @grades.map(&:learning_objective_outcomes).flatten
  if outcomes.present?
    json.array! outcomes do |outcome|
      json.type "learning_objective_outcomes"
      json.id outcome.id.to_s
      json.attributes do
        json.merge! outcome.attributes
      end
    end
  end
end

json.meta do
  json.student_ids @student_ids
  json.threshold_points     @assignment.threshold_points
  json.is_rubric_graded     @assignment.grade_with_rubric?
end
