class LearningObjectives::CategoriesController < ApplicationController
  before_action :ensure_staff?
  before_action :ensure_course_has_objectives?
  before_action :use_current_course

  def new
    @category = current_course.learning_objective_categories.new
  end

  def edit
    @category = current_course.learning_objective_categories.find params[:id]
  end

  private

  def ensure_course_has_objectives?
    redirect_to dashboard_path unless current_course.has_learning_objectives?
  end
end
