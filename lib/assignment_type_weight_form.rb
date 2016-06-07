class AssignmentTypeWeightForm < Struct.new(:student, :course)
  extend ActiveModel::Naming
  include ActiveModel::Validations
  include ActiveModel::Conversion

  attr_reader :assignment_type_weights

  validate :validate_course_total_weights
  validate :validate_assignment_type_weights
  validate :validate_course_max_assignment_types_weighted
  validate :validate_max_per_assignment_type_weight

  def update_attributes(attributes)
    self.assignment_type_weights_attributes = attributes[:assignment_type_weights_attributes]
    save
  end

  def save
    if valid?
      assignment_type_weights.map(&:save)
      true
    else
      false
    end
  end

  def assignment_type_weights
    @assignment_type_weights ||= course.assignment_types.student_weightable.map do |assignment_type|
      AssignmentTypeWeightStruct.new(student, assignment_type)
    end
  end

  def assignment_type_weights_attributes=(attributes_collection)
    @assignment_type_weights = attributes_collection.map do |key, attributes|
      AssignmentTypeWeightStruct.new(student, AssignmentType.find(attributes["assignment_type_id"])).tap do |assignment_type_weight|
        assignment_type_weight.weight = attributes["weight"].to_i
      end
    end
  end

  # Counting how many total weights have been assigned to make sure it's at/below the cap
  def course_total_weights
    assignment_type_weights.sum(&:weight)
  end

  # Counting how many assignment types the student has weighted to ensure it's at/below the cap
  def num_assignment_type_weights
    assignment_type_weights.select { |atw| atw.weight > 0  }.count
  end

  private

  def validate_course_total_weights
    if course.total_weights.present?
      if course_total_weights > course.total_weights
        errors.add(:base, "You have allocated more than the course total")
      elsif course_total_weights < course.total_weights
        errors.add(:base, "You must allocate the entire course total")
      end
    end
  end

  def validate_max_per_assignment_type_weight
    assignment_type_weights.each do |assignment_type_weight|
      if assignment_type_weight.weight > course.max_weights_per_assignment_type
        errors.add(:base, "You have allocated more to #{assignment_type_weight.assignment_type.name} than permitted")
      end
    end
  end

  def validate_course_max_assignment_types_weighted
    if course.max_assignment_types_weighted.present?
      if num_assignment_type_weights > course.max_assignment_types_weighted
        errors.add(:base, "You have weighted more assignment types than the course allows")
      end
    end
  end

  def validate_assignment_type_weights
    assignment_type_weights.each do |assignment_type_weight|
      if !assignment_type_weight.valid?
        assignment_type_weight.errors.each do |attribute, message|
          attribute = "assignment_type_weights.#{attribute}"
          errors[attribute] << message
          errors[attribute].uniq!
        end
      end
    end
  end
end
