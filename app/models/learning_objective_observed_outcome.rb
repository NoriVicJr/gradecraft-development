class LearningObjectiveObservedOutcome < ActiveRecord::Base
  belongs_to :objective, class_name: "LearningObjective", optional: true
  belongs_to :objective_level, class_name: "LearningObjectiveLevel"
  belongs_to :learning_objective_assessable, polymorphic: true

  validates_presence_of :assessed_at, :objective_level
end
