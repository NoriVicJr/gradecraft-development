class LearningObjectiveCategory < ActiveRecord::Base
  belongs_to :course

  validates_presence_of :course, :name
  validates :allowable_yellow_warnings, numericality: { greater_than_or_equal_to: 0 }
end
