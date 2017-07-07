class API::AttendanceController < ApplicationController
  before_action :ensure_staff?

  # def new
  #   render json: { message: "No class days were selected", success: false },
  #     status: 400 and return if params[:selectedDays].blank?
  #
  #   if params[:has_points]
  #     # Creating assignments
  #     @events = params[:selectedDays].map do |day|
  #       Assignment.new do |a|
  #         a.due_at = params[:startDate],
  #         a.open_at = params[:endDate]
  #       end
  #     end
  #   else
  #     # Creating events
  #   end
  #   binding.pry
  # end

  # POST api/attendance
  def create

  end
end
