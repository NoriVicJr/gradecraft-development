class LearningObjectives::ObjectivesController < ApplicationController
  before_action :ensure_staff?
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def index
  end

  def new
    @category = current_course.learning_objective_categories.find(params[:category_id]) \
      unless params[:category_id].nil?
  end

  # GET /learning_objectives/objectives/:objective_id/linked_assignments
  def linked_assignments
    @objective = current_course.learning_objectives.find params[:objective_id]
  end

  def edit
    @objective = current_course.learning_objectives.find params[:id]
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
