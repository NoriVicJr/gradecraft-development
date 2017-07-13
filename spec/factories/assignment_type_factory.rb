FactoryGirl.define do
  factory :assignment_type do
    name { Faker::Lorem.word }
    course { create(:course) }

    trait :attendance do
      attendance true
      name "Attendance"
    end
  end
end
