FactoryGirl.define do
  factory :learning_objective_observed_outcome do
    association :learning_objective
    association :learning_objective_level

    assessed_at { Faker::Date.backward(60) }
    comments { Faker::Hipster.sentence }

    factory :learning_objective_observed_outcome_grade do
      association :learning_objective_assessable, factory: :grade
    end
  end
end
