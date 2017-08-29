FactoryGirl.define do
  factory :learning_objective_link do
    association :learning_objective

    factory :learning_objective_link_assignment do
      association :learning_objective_linkable, factory: :assignment
    end

    factory :learning_objective_link_assignment_type do
      association :learning_objective_linkable, factory: :assignment_type
    end
  end
end
