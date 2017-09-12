class LearningObjectiveCumulativeOutcome < ActiveRecord::Base
  belongs_to :user
  belongs_to :learning_objective

  has_many :observed_outcomes, class_name: "LearningObjectiveObservedOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id, dependent: :destroy

  validates_presence_of :user, :learning_objective
  validates :user, uniqueness: { scope: :learning_objective,
    message: "should be unique per learning objective" }

  scope :for_user, -> (user_id) { where(user_id: user_id) }

  def status
    return "Failed" if failed?
    outcomes = observed_outcomes
      .includes(:learning_objective_level)
      .where.not(learning_objective_levels: { flagged_value: LearningObjectiveLevel.flagged_values[:red] })
    outcomes.count < learning_objective.count_to_achieve ? "In progress" : "Completed"
  end

  def failed?
    flagged_red_outcomes.any?
    # TODO: can also fail if you have hit the allowable_yellow_warnings for a specific category
  end

  private

  def flagged_red_outcomes
    @flagged_red_outcomes ||= observed_outcomes
      .includes(:learning_objective_level)
      .where(learning_objective_levels: { flagged_value: LearningObjectiveLevel.flagged_values[:red] })
  end
end
