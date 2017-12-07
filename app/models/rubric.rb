class Rubric < ActiveRecord::Base
  include Copyable

  belongs_to :assignment
  belongs_to :course
  has_many :criteria, dependent: :destroy
  has_many :levels, through: :criteria
  has_many :level_badges, through: :criteria
  has_many :criterion_grades, through: :criteria

  validates :assignment, :course, presence: true

  def max_level_count
    criteria.inject([]) do |level_counts, criterion|
      level_counts << criterion.levels.count
    end.max
  end

  def designed?
    criteria.count > 0
  end

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes,
      associations: [:criteria],
      options: { lookups: [:courses, :assignments] }
    )
  end
end
