class LearningObjectives::OutcomesController < ApplicationController
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def index
    @cumulative_outcome = current_course
      .learning_objectives
      .find(params[:objective_id])
      .cumulative_outcomes
      .for_user current_student

    @observed_outcomes = @cumulative_outcome
      .observed_outcomes
      .includes(:learning_objective_level)
      .where(
        learning_objective_assessable_type: Grade.name
      )
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
