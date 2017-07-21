FactoryGirl.define do
  factory :learning_objective_category do
    association :course

    name { Faker::Commerce.department(5) }

    trait :with_allowable_yellow_warnings do
      allowable_yellow_warnings Faker::Number.between(1, 5)
    end
  end
end
