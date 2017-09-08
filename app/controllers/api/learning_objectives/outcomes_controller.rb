class API::LearningObjectives::OutcomesController < ApplicationController
  before_action :ensure_staff?, except: :index

  # GET /api/learning_objectives/outcomes
  def index
    if params[:assignment_id].present?
      outcomes = current_course
        .assignments
        .find(params[:assignment_id])
        .learning_objectives
        .includes(cumulative_outcomes: :observed_outcomes)
    else
      outcomes = current_course
        .learning_objectives
        .includes(cumulative_outcomes: :observed_outcomes)
    end
    
    @cumulative_outcomes = outcomes.map(&:cumulative_outcomes).flatten \
      unless outcomes.blank?
  end

  # PUT /api/assignments/:assignment_id/students/:student_id/learning_objectives/:learning_objective_id/update_outcome
  def update_outcome
    grade = Grade.find_by assignment_id: params[:assignment_id], student_id: params[:student_id]
    cumulative_outcome = find_cumulative_outcome_for grade.student_id
    observed_outcome = find_or_initialize_outcome_for cumulative_outcome, grade

    if observed_outcome.update learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now)
      render json: { message: "Outcome saved", success: true }, status: :ok
    else
      render json: { errors: observed_outcome.errors, success: false }, status: :bad_request
    end
  end

  # PUT /api/assignments/:assignment_id/groups/:group_id/learning_objectives/:learning_objective_id/update_outcome
  def group_update_outcome
    outcomes = []
    group = Group.find params[:group_id]

    group.students.each do |student|
      grade = Grade.find_by assignment_id: params[:assignment_id], student_id: student.id
      cumulative_outcome = find_cumulative_outcome_for grade.student_id
      observed_outcome = find_or_initialize_outcome_for cumulative_outcome, grade
      outcomes << observed_outcome.update(learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now))
    end

    if outcomes.all?
      render json: { message: "Outcome saved", success: true }, status: :ok
    else
      render json: { errors: outcomes.map(&:errors).pluck(:message).flatten.uniq, success: false },
        status: :bad_request
    end
  end

  private

  def learning_objective_outcome_params
    params.require(:learning_objective_outcome).permit(:comments, :objective_level_id)
  end

  def find_cumulative_outcome_for(user_id)
    objective = current_course.learning_objectives.find params[:learning_objective_id]
    objective.cumulative_outcomes.find_or_create_by user_id: user_id
  end

  def find_or_initialize_outcome_for(cumulative_outcome, grade)
    cumulative_outcome.observed_outcomes.find_or_initialize_by \
      learning_objective_assessable_type: Grade.name,
      learning_objective_assessable_id: grade.id
  end
end
