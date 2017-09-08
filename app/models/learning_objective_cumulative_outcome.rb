class LearningObjectiveCumulativeOutcome < ActiveRecord::Base
  belongs_to :user
  belongs_to :learning_objective

  has_many :observed_outcomes, class_name: "LearningObjectiveObservedOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id, dependent: :destroy

  validates_presence_of :user
  validates :user, uniqueness: { scope: :learning_objective,
    message: "should be one cumulative outcome per user, learning objective" }

  scope :for_user, -> (user_id) { where(user_id: user_id) }

  def failed?
    observed_outcomes
  end
end
