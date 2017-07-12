# rubocop:disable AndOr
class AttendanceController < ApplicationController
  before_action :find_or_create_assignment_type, only: :new

  def index
    redirect_to action: :new and return if !current_course.assignments.with_attendance_type.any?

    @attendance_assignments = Assignment.with_attendance_type
  end

  def new

  end

  private

  def find_or_create_assignment_type
    @assignment_type = AssignmentType.attendance_type_for current_course
    @assignment_type = current_course.assignment_types.create(attendance: true, name: "Attendance") if @assignment_type.nil?
  end
end
