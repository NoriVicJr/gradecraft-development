class LearningObjectiveCategory < ActiveRecord::Base
  belongs_to :course

  has_many :learning_objectives, foreign_key: :category_id, dependent: :destroy

  validates_presence_of :course, :name
  validates :allowable_yellow_warnings, numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true

  def failed?
    return false if allowable_yellow_warnings.nil?
    observed_outcomes = LearningObjectiveObservedOutcome
      .where(cumulative_outcome: learning_objectives.select(&:cumulative_outcomes).pluck(:id))
    observed_outcomes.for_flagged_value(LearningObjectiveLevel.flagged_values[:yellow]).count > allowable_yellow_warnings
  end
end
