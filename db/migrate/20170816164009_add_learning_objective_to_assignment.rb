class AddLearningObjectiveToAssignment < ActiveRecord::Migration[5.0]
  def change
    add_reference :assignments, :learning_objective, foreign_key: true
  end
end
