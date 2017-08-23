FactoryGirl.define do
  factory :learning_objective_observed_outcome do
    association :objective, factory: :learning_objective
    association :objective_level, factory: :learning_objective_level

    assessed_at { Faker::Date.backward(60) }
    comments { Faker::Hipster.sentence }

    factory :learning_objective_observed_outcome_grade do
      association :learning_objective_assessable, factory: :grade
    end
  end
end
