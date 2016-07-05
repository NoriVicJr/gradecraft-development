FactoryGirl.define do
  factory :assignment do
    name { Faker::Lorem.word }
    association :course
    association :assignment_type
    description { Faker::Lorem.sentence }
    full_points { Faker::Number.number(5) }
    required false
    student_logged false
    release_necessary false
    resubmissions_allowed false
    hide_analytics false
    grade_scope "Individual"
    accepts_submissions true
    visible true
    include_in_timeline true
    include_in_predictor true
    include_in_to_do true
    use_rubric true
    accepts_attachments true
    accepts_text true
    accepts_links true
    pass_fail false
    visible_when_locked true
    show_name_when_locked true
    show_points_when_locked true
    threshold_points 0
    show_description_when_locked true
    show_purpose_when_locked true

    factory :individual_assignment do
      grade_scope "Individual"
    end

    factory :group_assignment do
      grade_scope "Group"
    end

    factory :individual_assignment_with_submissions do
      grade_scope "Individual"
      accepts_submissions true
    end
  end
end
