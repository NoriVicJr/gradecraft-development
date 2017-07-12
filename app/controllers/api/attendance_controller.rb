class API::AttendanceController < ApplicationController
  before_action :ensure_staff?

  # POST api/attendance
  def create
    if current_course.update assignments_params
      # render assignment params
    else
      render json: { message: "Failed to update assignments", success: false },
        status: :internal_server_error
    end
  end

  private

  def assignments_params
    params.permit(assignments_attributes: [:id, :name, :description,
      :open_at, :due_at, :assignment_type_id])
  end
end
