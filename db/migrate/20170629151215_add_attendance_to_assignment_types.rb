class AddAttendanceToAssignmentTypes < ActiveRecord::Migration[5.0]
  def change
    add_column :assignment_types, :attendance, :boolean, default: false, null: false
  end
end
