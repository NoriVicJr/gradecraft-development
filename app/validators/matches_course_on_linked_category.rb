class MatchesCourseOnLinkedCategory < ActiveModel::Validator
  def validate(record)
    record.errors[:invalid_course] << "Course for objective must match course for linked category" \
      if record.category.present? && (record.course != record.category.course)
  end
end
