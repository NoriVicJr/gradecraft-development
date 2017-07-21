class CreateLearningObjectiveLevel < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objective_levels do |t|
      t.integer :objective_id, null: false
      t.string :name, null: false
      t.string :description
      t.integer :flagged_value, null: false
    end

    add_foreign_key :learning_objective_levels, :learning_objectives, column: :objective_id
  end
end
