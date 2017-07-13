class API::AttendanceController < ApplicationController
  before_action :ensure_staff?

  # POST api/attendance
  # Creates/updates many assignments from the given nested attributes
  def create
    if current_course.update assignments_params
      @assignments = current_course.assignments.with_attendance_type
    else
      render json: { message: "Failed to update assignments", success: false },
        status: :internal_server_error
    end
  end

  private

  def assignments_params
    params.permit(assignments_attributes: [:id, :name, :description,
      :open_at, :due_at, :assignment_type_id, :full_points, :pass_fail])
  end
end
