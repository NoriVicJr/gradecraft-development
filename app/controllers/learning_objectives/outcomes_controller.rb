class LearningObjectives::OutcomesController < ApplicationController
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def index
    @learning_objective = current_course.learning_objectives.find params[:objective_id]
    @cumulative_outcome = @learning_objective
      .cumulative_outcomes
      .for_user(current_user.id)
      .first unless @learning_objective.nil?
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
