class API::LearningObjectives::OutcomesController < ApplicationController
  before_action :ensure_staff?

  # PUT /api/assignments/:assignment_id/students/:student_id/learning_objective_outcomes/:id/update_fields
  def update_fields
    grade = Grade.find_by assignment_id: params[:assignment_id], student_id: params[:student_id]
    @outcome = find_or_create_for grade

    if @outcome.update learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now)
      # render "api/criterion_grades/show", success: true,
      # status: 200
      render json: { message: "Outcome saved", success: true }, status: :ok
    else
      render json: { errors: @outcome.errors, success: false }, status: :bad_request
    end
  end

  # PUT /api/assignments/:assignment_id/groups/:group_id/learning_objective_outcomes/:id/update_fields
  def group_update_fields
    @outcomes = []
    group = Group.find params[:group_id]

    group.students.each do |student|
      grade = Grade.find_by assignment_id: params[:assignment_id], student_id: student.id
      outcome = find_or_create_for grade
      @outcomes << outcome.update_attributes(learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now))
    end

    if @outcomes.all?
      render json: { message: "Outcome saved", success: true }, status: :ok
      # render "api/criterion_grades/index", success: true,
      # status: 200
    else
      render json: { errors: @outcomes.map(&:errors).pluck(:message).flatten.uniq, success: false },
        status: :bad_request
    end
  end

  private

  def learning_objective_outcome_params
    params.require(:learning_objective_outcome).permit(:comments, :objective_id, :objective_level_id)
  end

  def find_or_create_for(grade)
    grade.learning_objective_outcomes.find_or_initialize learning_objective_outcome_params[:objective_id]
  end
end
