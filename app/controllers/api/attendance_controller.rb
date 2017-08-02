class API::AttendanceController < ApplicationController
  before_action :ensure_staff?

  # GET /api/attendance
  def index
    @assignments = current_course.assignments.with_attendance_type
  end

  # POST /api/attendance
  def create
    @attendance_event = current_course.assignments.new \
      assignment_params.merge(assignment_type_id: AssignmentType.attendance_type_for(current_course).id)

    if @attendance_event.save
      render "api/attendance/show", status: 201
    else
      render json: {
        message: "Failed to create attendance event",
        errors: @attendance_event.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/attendance/:id
  def update
    @attendance_event = current_course.assignments.find params[:id]

    if @attendance_event.update_attributes assignment_params
      render "api/attendance/show", status: 200
    else
      render json: {
        message: "Failed to update attendance event",
        errors: @attendance_event.errors.messages,
        success: false
      }, status: 400
    end
  end

  private

  def assignment_params
    params.require(:assignment).permit :id, :name, :description,
      :open_at, :due_at, :full_points, :pass_fail, :media
  end
end
