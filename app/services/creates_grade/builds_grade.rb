module Services
  module Actions
    class BuildsGrade
      extend LightService::Action

      expects :attributes, :student, :assignment, :graded_by_id
      promises :grade

      executed do |context|
        grade = Grade.find_or_create(context[:assignment].id, context[:student].id)
        update_grade_attributes grade, context[:attributes]["grade"]
        grade.graded_at = DateTime.now
        grade.graded_by_id = context[:graded_by_id]
        grade.full_points = context[:assignment].full_points
        grade.group_id = context[:attributes]["group_id"] if context[:attributes]["group_id"]
        context[:grade] = grade
      end

      private

      # Updates the given attributes on the grade
      # Ideally this will be replaced by grade.assign_attributes context[:attributes]["grade"]
      # once we have identified and permitted inputs from all consumers of this service with strong params
      def self.update_grade_attributes(grade, attributes)
        attributes.each_pair do |key, value|
          method = "#{key}="
          grade.send method, value if grade.respond_to? method
        end
      end
    end
  end
end
