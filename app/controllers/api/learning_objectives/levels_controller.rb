class API::LearningObjectives::LevelsController < ApplicationController
  before_action :ensure_staff?
  before_action :find_objective

  # POST /api/learning_objectives/:objective_id/levels
  def create
    @level = @objective.levels.new learning_objective_level_params

    if @level.save
      render "api/learning_objectives/levels/show", status: 201
    else
      render json: {
        message: "Failed to create learning objective level",
        errors: @level.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/learning_objectives/:objective_id/levels/:id
  def update
    @level = @objective.levels.find params[:id]

    if @level.update_attributes learning_objective_level_params
      render "api/learning_objectives/levels/show", status: 200
    else
      render json: {
        message: "Failed to update learning objective level",
        errors: @level.errors.messages,
        success: false
      }, status: 400
    end
  end

  # DELETE /api/learning_objectives/:objective_id/levels/:id
  def destroy
    @level = @objective.levels.find params[:id]
    @level.destroy

    if @level.destroyed?
      render json: { message: "Successfully deleted #{@level.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@level.name}", success: false },
        status: 500
    end
  end

  private

  def learning_objective_level_params
    params.require(:learning_objective_level).permit :id, :name, :description,
      :learning_objective_id, :flagged_value
  end

  def find_objective
    @objective = current_course.learning_objectives.find(params[:objective_id])
  end
end
