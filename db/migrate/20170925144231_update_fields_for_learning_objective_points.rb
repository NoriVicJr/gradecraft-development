class UpdateFieldsForLearningObjectivePoints < ActiveRecord::Migration[5.0]
  def change
    add_column :learning_objectives, :points_to_completion, :integer
    change_column :learning_objective_levels, :flagged_value, :integer, null: true
  end
end
