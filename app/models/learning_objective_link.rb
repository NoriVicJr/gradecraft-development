class LearningObjectiveLink < ActiveRecord::Base
  belongs_to :learning_objective, foreign_key: :objective_id
  belongs_to :learning_objective_linkable, polymorphic: true
  belongs_to :course

  validates_presence_of :learning_objective
end
