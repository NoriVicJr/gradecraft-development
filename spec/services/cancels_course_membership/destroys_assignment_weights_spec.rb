require "light-service"
require "active_record_spec_helper"
require "./app/services/cancels_course_membership/destroys_assignment_type_weights"

describe Services::Actions::DestroysAssignmentTypeWeights do
  let(:course) { membership.course }
  let(:membership) { create :student_course_membership }
  let(:student) { membership.user }

  it "expects the membership to find the assignment weights to destroy" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "destroys the assignment weights" do
    another_weight = create :assignment_type_weight, student: student
    course_weight = create :assignment_type_weight, student: student, course: course
    described_class.execute membership: membership
    expect(student.reload.assignment_type_weights).to eq [another_weight]
  end
end
