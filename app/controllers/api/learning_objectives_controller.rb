class API::LearningObjectivesController < ApplicationController
  before_action :ensure_staff?
  before_action :find_objective, only: [:update, :destroy]

  # POST /api/learning_objectives
   def create
     @learning_objective = current_course.learning_objectives.new learning_objective_params

     if @learning_objective.save
       render "api/learning_objectives/show.json.jbuilder", status: 201
     else
       render json: {
         message: "Failed to create learning objective",
         errors: @learning_objective.errors.messages,
         success: false
       }, status: 400
     end
   end

   # PUT /api/learning_objectives/:id
   def update
     if @learning_objective.update_attributes learning_objective_params
       render "api/learning_objectives/show.json.jbuilder", status: 200
     else
       render json: {
         message: "Failed to update learning objective",
         errors: @learning_objective.errors.messages,
         success: false
       }, status: 400
     end
   end

   # DELETE /api/learning_objectives/:id
   def destroy
     @learning_objective.destroy

     if @learning_objective.destroyed?
       render json: { message: "Successfully deleted #{@learning_objective.name}", success: true },
         status: 200
     else
       render json: { message: "Failed to delete #{@learning_objective.name}", success: false },
         status: 500
     end
   end

   private

   def learning_objective_params
     params.require(:learning_objective).permit :id, :name, :description,
      :count_to_achieve
   end

   def find_objective
     @learning_objective = current_course.learning_objectives.find params[:id]
   end
end
