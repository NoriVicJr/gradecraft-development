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
end
