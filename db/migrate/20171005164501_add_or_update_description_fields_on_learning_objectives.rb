class AddOrUpdateDescriptionFieldsOnLearningObjectives < ActiveRecord::Migration[5.0]
  def change
    add_column :learning_objective_categories, :description, :text
    change_column :learning_objectives, :description, :text
  end
end
