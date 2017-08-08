class CreateLearningObjectiveOutcome < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objective_outcomes do |t|
      t.integer :course_id
      t.integer :objective_id
      t.integer :objective_level_id, null: false
      t.datetime :assessed_at, null: false
      t.text :description

      t.timestamps

      t.references :learning_objective_assessable, polymorphic: true, index: {
        name: "index_learning_objective_outcomes_on_type_and_id" }
    end
  end
end
