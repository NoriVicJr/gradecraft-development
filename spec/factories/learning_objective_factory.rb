FactoryGirl.define do
  factory :learning_objective do
    association :course

    name { Faker::Hacker.ingverb }
    description { Faker::Hacker.say_something_smart }

    trait :with_count_to_achieve do
      count_to_achieve Faker::Number.between(1, 5)
    end

    trait :categorized do
      association :category, factory: :learning_objective_category
    end
  end
end
