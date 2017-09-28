class LearningObjectives::LinksController < ApplicationController
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def index
    @objectives = current_course.learning_objectives.includes(:assignments)
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
