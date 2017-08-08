class CreateLearningObjectiveLink < ActiveRecord::Migration[5.0]
  def change
    create_table :learning_objective_links do |t|
      t.integer :course_id
      t.integer :objective_id, null: false

      t.timestamps
      
      t.references :learning_objective_linkable, polymorphic: true, index: {
        name: "index_learning_objective_links_on_type_and_id" }
    end
  end
end
