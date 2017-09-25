class LearningObjective < ActiveRecord::Base
  belongs_to :course
  belongs_to :category, class_name: "LearningObjectiveCategory", optional: true

  has_many :levels, class_name: "LearningObjectiveLevel",
    foreign_key: :objective_id, dependent: :destroy
  has_many :cumulative_outcomes, class_name: "LearningObjectiveCumulativeOutcome",
    foreign_key: :learning_objective_id, dependent: :destroy

  has_many :learning_objective_links, foreign_key: :objective_id, dependent: :destroy
  has_many :assignments, source: :learning_objective_linkable,
    source_type: Assignment.name, through: :learning_objective_links

  validates_presence_of :course, :name
  validate :count_to_achieve_or_points
  validates :count_to_achieve, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates_with MatchesCourseOnLinkedCategory

  scope :ordered_by_name, -> { order :name }

  private

  # Ensure that objectives have either a count to achieve or a points to completion value
  def count_to_achieve_or_points
    if count_to_achieve.nil? && points_to_completion.nil?
      errors.add(:base, "must have either a count_to_achieve or points_to_completion")
    end
  end
end
