# rubocop:disable AndOr
class AttendanceController < ApplicationController
  def index
    redirect_to action: :new and return if !Attendance.has_attendance_articles_for? current_course

    @attendance_assignments = Assignment.with_attendance_type
    @attendance_events = Event.attendance
  end

  def new

  end
end
