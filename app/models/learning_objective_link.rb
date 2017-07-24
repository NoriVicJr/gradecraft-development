class LearningObjectiveLink < ActiveRecord::Base
  belongs_to :objective, class_name: "LearningObjective"
  belongs_to :learning_objective_linkable, polymorphic: true

  validates_presence_of :objective
end
