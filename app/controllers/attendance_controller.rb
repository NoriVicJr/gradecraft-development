# rubocop:disable AndOr
class AttendanceController < ApplicationController
  before_action :ensure_staff?
  before_action :find_or_create_assignment_type, except: :index

  # GET /attendance
  def index
    redirect_to action: :setup and return if !has_attendance_events?

    @assignments = current_course.assignments.with_attendance_type
  end

  # GET /attendance/new
  def new
    @assignment = Assignment.new
  end

  # POST /attendance/setup
  def setup
    redirect_to action: :index and return if has_attendance_events?
  end

  private

  def find_or_create_assignment_type
    @assignment_type = AssignmentType.attendance_type_for current_course
    @assignment_type = current_course.assignment_types.create(attendance: true, name: "Attendance") if @assignment_type.nil?
  end

  def has_attendance_events?
    current_course.assignments.with_attendance_type.any?
  end
end
