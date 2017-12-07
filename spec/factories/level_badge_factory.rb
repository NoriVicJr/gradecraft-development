FactoryGirl.define do
  factory :level_badge do

    before(:create) do |lb|
      c = create :course
      a = create :assignment, course: c
      r = create :rubric_with_criteria, course: c, assignment: a
      lb.level = r.criteria.last.levels.last
      lb.badge = create :badge, course: c
    end
  end

  # for specs that need to pass a level and/or badge into a level_badge
  # be warned that the courses will not be the same for these models,
  # it would be best to write these tests using the level badge above
  factory :dummy_level_badge, :class => LevelBadge do
    association :badge
    association :level
  end
end
