class LearningObjectiveCumulativeOutcome < ActiveRecord::Base
  belongs_to :user
  belongs_to :learning_objective

  has_many :observed_outcomes, class_name: "LearningObjectiveObservedOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id

  validates :user, presence: true, uniqueness: true

  scope :for_user, -> (user_id) { where(user_id: user_id) }

  def failed?
    observed_outcomes
  end
end
