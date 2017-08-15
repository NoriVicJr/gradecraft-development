class LearningObjectives::ObjectivesController < ApplicationController
  before_action :ensure_staff?
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def index
    redirect_to action: :setup if !@course.learning_objectives.any?
  end

  def edit
    @objective = current_course.learning_objectives.find params[:id]
  end

  def setup
    # redirect_to action: :index if @course.learning_objectives.any?
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
