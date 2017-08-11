class LearningObjectiveLevel < ActiveRecord::Base
  enum flagged_value: [ :yellow, :red ]

  belongs_to :objective, class_name: "LearningObjective",
    foreign_key: :objective_id

  validates_presence_of :name, :flagged_value, :objective
end
