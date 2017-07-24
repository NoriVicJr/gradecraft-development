class AddLearningObjectiveFieldsToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :learning_objective_term, :string,
      default: "Learning Objectives", null: false
    add_column :courses, :has_learning_objectives, :boolean,
      default: false, null: false
  end
end
