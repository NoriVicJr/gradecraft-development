class AddAllowsLearningObjectivesToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :allows_learning_objectives, :boolean, default: false, null: false
  end
end
