class LearningObjectiveObservedOutcome < ActiveRecord::Base
  belongs_to :learning_objective, foreign_key: :objective_id
  belongs_to :learning_objective_level, foreign_key: :objective_level_id
  belongs_to :learning_objective_assessable, polymorphic: true

  validates_presence_of :assessed_at, :learning_objective_level

  def self.find_or_initialize(objective_id)
    find_or_initialize_by objective_id: objective_id
  end
end
