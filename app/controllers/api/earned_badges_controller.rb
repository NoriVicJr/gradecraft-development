require_relative "../../services/creates_earned_badge"
require_relative "../../services/notifies_earned_badge"

class API::EarnedBadgesController < ApplicationController
  skip_before_action :require_login, only: :confirm_earned
  skip_before_action :require_course_membership, only: :confirm_earned
  before_action :ensure_staff?, except: :confirm_earned

  # Used for Badges Backpack integration
  # GET /api/courses/:course_id/badges/:badge_id/earned_badges/:id/confirm_earned
  def confirm_earned
    @course = Course.find_by_id(params[:course_id])
    @badge = @course.badges.find_by_id(params[:badge_id]) unless @course.nil?

    if @badge.present? && @badge.earned_badges.find_by_id(params[:id]).present?
      head 200
    else
      render json: { message: "Earned badge not found", success: false }, status: 404
    end
  end

  # POST /api/earned_badges
  def create
    result = Services::CreatesEarnedBadge.award earned_badge_params.merge(awarded_by: current_user),
      params[:notify]
    if result.success?
      @earned_badge = result.earned_badge
      render status: 201
    else
      render json: { message: result.message, success: false }, status: 400
    end
  end

  # DELETE /api/earned_badges/:id
  def destroy
    earned_badge = EarnedBadge.where(id: params[:id]).first
    if earned_badge.present? && earned_badge.destroy
      render json: { message: "Earned badge successfully deleted", success: true },
        status: 200
    else
      render json: { message: "Earned badge failed to delete", success: false },
        status: 400
    end
  end

  # PUT /api/earned_badges/notify
  def notify
    head :bad_request and return if params[:earned_badge_ids].blank?
    earned_badges = EarnedBadge.where id: params[:earned_badge_ids]
    results = earned_badges.map { |eb| Services::NotifiesEarnedBadge.notify eb }

    if results.all?(&:success?)
      head :ok
    else
      render json: { message: "An error occurred while notifying earned badge recipients", success: false },
        status: 500
    end
  end

  private

  def earned_badge_params
    params.require(:earned_badge).permit(:feedback, :student_id, :badge_id,
      :grade_id)
  end
end
