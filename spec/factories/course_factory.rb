FactoryGirl.define do
  factory :course do
    name { Faker::Internet.domain_word }
    course_number { Faker::Internet.domain_word }
    semester "Fall"
    has_badges false
    has_paid false
    published true
    # learning_objective_term "Learning Objectives"

    factory :course_with_weighting do
      total_weights 6
      max_weights_per_assignment_type 4
      max_assignment_types_weighted 2
    end

    factory :invalid_course do
      name nil
    end

    trait :with_institution do
      association :institution
    end
  end
end
