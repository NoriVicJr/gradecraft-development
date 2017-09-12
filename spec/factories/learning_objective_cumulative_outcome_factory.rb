FactoryGirl.define do
  factory :learning_objective_cumulative_outcome do
    association :user
    association :learning_objective
  end
end
