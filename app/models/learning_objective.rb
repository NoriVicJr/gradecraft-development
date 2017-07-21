class LearningObjective < ActiveRecord::Base
  belongs_to :course
  belongs_to :category, class_name: 'LearningObjectiveCategory', optional: true

  validates_presence_of :course, :name
  validates :count_to_achieve, numericality: { greater_than_or_equal_to: 0 }
  validates_with MatchesCourseOnLinkedCategory
end
