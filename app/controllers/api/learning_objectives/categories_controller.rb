class API::LearningObjectives::CategoriesController < ApplicationController
  before_action :ensure_staff?
  before_action :find_category, only: [:show, :update, :destroy]

  # GET /api/learning_objectives/categories
  def index
    @categories = current_course.learning_objective_categories.all
  end

  def show
    render "api/learning_objectives/categories/show", status: 200
  end

  # POST /api/learning_objectives/categories
  def create
    @category = current_course.learning_objective_categories.new \
      learning_objective_category_params

    if @category.save
      render "api/learning_objectives/categories/show", status: 201
    else
      render json: {
        message: "Failed to create learning objective category",
        errors: @category.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/learning_objectives/categories/:id
  def update
    if @category.update_attributes learning_objective_category_params
      render "api/learning_objectives/categories/show", status: 200
    else
      render json: {
        message: "Failed to update learning objective category",
        errors: @category.errors.messages,
        success: false
      }, status: 400
    end
  end

  # DELETE /api/learning_objectives/categories/:id
  def destroy
    @category.destroy

    if @category.destroyed?
      render json: { message: "Successfully deleted #{@category.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@category.name}", success: false },
        status: 500
    end
  end

  private

  def learning_objective_category_params
    params.require(:learning_objective_category).permit :id, :name,
      :allowable_yellow_warnings
  end

  def find_category
    @category = current_course.learning_objective_categories.find params[:id]
  end
end
