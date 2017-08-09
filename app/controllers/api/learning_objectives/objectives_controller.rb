class API::LearningObjectives::ObjectivesController < ApplicationController
  before_action :ensure_staff?
  before_action :find_objective, only: [:update, :destroy]

  # GET /api/learning_objectives/objectives
  def index
    @objectives = current_course.learning_objectives.all
  end

  # POST /api/learning_objectives/objectives
   def create
     @objective = current_course.learning_objectives.new learning_objective_params

     if @objective.save
       render "api/learning_objectives/objectives/show", status: 201
     else
       render json: {
         message: "Failed to create learning objective",
         errors: @objective.errors.messages,
         success: false
       }, status: 400
     end
   end

   # PUT /api/learning_objectives/objectives/:id
   def update
     if @objective.update_attributes learning_objective_params
       render "api/learning_objectives/objectives/show", status: 200
     else
       render json: {
         message: "Failed to update learning objective",
         errors: @objective.errors.messages,
         success: false
       }, status: 400
     end
   end

   # DELETE /api/learning_objectives/objectives/:id
   def destroy
     @objective.destroy

     if @objective.destroyed?
       render json: { message: "Successfully deleted #{@objective.name}", success: true },
         status: 200
     else
       render json: { message: "Failed to delete #{@objective.name}", success: false },
         status: 500
     end
   end

   private

   def learning_objective_params
     params.require(:learning_objective).permit :id, :name, :description,
      :count_to_achieve, :category_id
   end

   def find_objective
     @objective = current_course.learning_objectives.find params[:id]
   end
end
