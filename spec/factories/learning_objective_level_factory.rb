FactoryGirl.define do
  factory :learning_objective_level do
    association :objective, factory: :learning_objective

    name { Faker::Hacker.noun }
    description { Faker::Hacker::say_something_smart }

    factory :learning_objective_level_yellow do
      flagged_value :yellow
    end

    factory :learning_objective_level_red do
      flagged_value :red
    end
  end
end
