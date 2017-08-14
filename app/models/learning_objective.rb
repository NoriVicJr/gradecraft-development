class LearningObjective < ActiveRecord::Base
  belongs_to :course
  belongs_to :category, class_name: "LearningObjectiveCategory", optional: true

  has_many :levels, class_name: "LearningObjectiveLevel",
    foreign_key: :objective_id, dependent: :destroy
  has_many :links, class_name: "LearningObjectiveLink",
    as: :learning_objective_linkable, dependent: :destroy

  validates_presence_of :course, :name
  validates :count_to_achieve, numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true
  validates_with MatchesCourseOnLinkedCategory
end
