FactoryGirl.define do
  factory :level_badge do
    association :level
    association :badge

    before(:create) do |lb|
      course =
    end
  end
end
