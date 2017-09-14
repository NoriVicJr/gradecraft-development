class LearningObjectiveObservedOutcome < ActiveRecord::Base
  belongs_to :cumulative_outcome, class_name: "LearningObjectiveCumulativeOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id
  belongs_to :learning_objective_level, foreign_key: :objective_level_id
  belongs_to :learning_objective_assessable, polymorphic: true

  belongs_to :grade, foreign_key: :learning_objective_assessable_id

  validates_presence_of :assessed_at, :learning_objective_level

  scope :for_grades, -> { where learning_objective_assessable_type: Grade.name }
end
