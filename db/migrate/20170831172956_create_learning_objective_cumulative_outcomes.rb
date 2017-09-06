# For handling the overall progress of a learning objective
class CreateLearningObjectiveCumulativeOutcomes < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objective_cumulative_outcomes do |t|
      t.timestamps

      t.references :learning_objective, index: true, foreign_key: true,
        index: { name: "index_lo_cumulative_outcomes_on_objective_id" }
      t.belongs_to :user, foreign_key: true, index: { unique: true }
    end

    add_reference :learning_objective_observed_outcomes, :learning_objective_cumulative_outcomes,
      foreign_key: true, index: { name: "index_lo_observed_outcomes_on_cumulative_outcomes_id" }
    remove_column :learning_objective_observed_outcomes, :objective_id
  end
end
