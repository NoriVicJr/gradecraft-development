class AddPublishedToCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :courses, :published, :boolean, default: false, null: false
  end
end
