# rubocop:disable AndOr
class API::AttendanceController < ApplicationController
  before_action :ensure_staff?

  def index
    assign_attendance_assignments
  end

  # POST api/attendance
  # Creates/updates many assignments from the given nested attributes
  def create_or_update
    render json: { message: "Bad request", success: false },
      status: :bad_request and return if assignments_params.blank?

    if current_course.update assignments_params
      assign_attendance_assignments
    else
      render json: { message: "Failed to update attendance assignments", success: false },
        status: :internal_server_error
    end
  end

  private

  def assignments_params
    params.permit assignments_attributes: [:id, :name, :description,
      :open_at, :due_at, :assignment_type_id, :full_points, :pass_fail]
  end

  def assign_attendance_assignments
    @assignments = current_course.assignments.with_attendance_type
  end
end
