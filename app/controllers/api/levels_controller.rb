require_relative "../../services/removes_criterion_expectations"

class API::LevelsController < ApplicationController
  before_action :ensure_staff?

  def create
    @level = Level.new(level_params)
    if @level.save
      render "api/levels/show", status: 201
    else
      render json: { message: "level failed to create", success: false }, status: 400
    end
  end

  # PUT api/levels/:id
  def update
    @level = Level.find(params[:id])

    if @level.update_attributes(level_params)
      render "api/levels/show", status: 200
    else
      render json: {
        errors: [{ detail: "failed to update level" }], success: false
        },
        status: 500
    end
  end

  # DELETE api/levels/:id
  def destroy
    level = Level.find(params[:id])
    if level.meets_expectations
      result = Services::RemovesCriterionExpectations.update level.criterion
    end
    if level.destroy
      render json: { message: "level successfully deleted", success: true },
        status: 200
    else
      render json: { message: "level failed to delete", success: false },
        status: 400
    end
  end

  private

  def updating_meets_expectations?
    params[:level][:meets_expectations] == true
  end

  def level_params
    params.require(:level).permit(:criterion_id, :description, :name, :points)
  end
end
