class CreateLearningObjective < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objectives do |t|
      t.string :name, null: false
      t.string :description
      t.integer :count_to_achieve
      t.integer :category_id
      t.integer :course_id, null: false
    end

    add_foreign_key :learning_objectives, :learning_objective_categories, column: :category_id
    add_foreign_key :learning_objectives, :courses
  end
end
