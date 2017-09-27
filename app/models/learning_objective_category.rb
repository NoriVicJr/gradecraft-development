class LearningObjectiveCategory < ActiveRecord::Base
  belongs_to :course

  has_many :learning_objectives, foreign_key: :category_id,
    class_name: "LearningObjective", dependent: :destroy

  validates_presence_of :course, :name
  validates :allowable_yellow_warnings, numericality: { greater_than_or_equal_to: 0 },
    allow_nil: true

  def failed?(yellow_outcomes)
    return false if allowable_yellow_warnings.nil?
    yellow_outcomes.count > allowable_yellow_warnings
  end
end
