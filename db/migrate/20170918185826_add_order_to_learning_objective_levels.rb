class AddOrderToLearningObjectiveLevels < ActiveRecord::Migration[5.0]
  def change
    add_column :learning_objective_levels, :order, :integer
  end
end
