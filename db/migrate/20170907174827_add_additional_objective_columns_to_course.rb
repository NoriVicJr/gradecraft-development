class AddAdditionalObjectiveColumnsToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :objectives_award_points, :boolean, default: false, null: false
    add_column :courses, :always_show_objectives, :boolean, default: false, null: false
  end
end
