class AddLearningObjectiveFieldsToCourses < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :learning_objective_term, :integer,
      default: 0, null: false
    add_column :courses, :has_learning_objectives, :boolean,
      default: false, null: false
  end
end
