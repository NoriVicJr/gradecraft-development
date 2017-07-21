class LearningObjectiveCategory < ActiveRecord::Base
  belongs_to :course

  has_many :learning_objectives, class_name: "LearningObjective"

  validates_presence_of :course, :name
  validates :allowable_yellow_warnings, numericality: { greater_than_or_equal_to: 0 }
end
