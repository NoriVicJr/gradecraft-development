require "rails_spec_helper"
include CourseTerms

describe "submissions/show" do

  let(:presenter) do
    ShowSubmissionPresenter.new(
      course: course,
      id: submission.id,
      assignment_id: assignment.id,
      group_id: group.id,
      view_context: view_context
    )
  end

  let(:view_context) { double(:view_context, points: "12,000") }
  let(:course) { create(:course) }
  let(:assignment) { build(:group_assignment, course: course) }
  let(:group) { create(:group, course: course) }
  let(:submission) { create(:submission, course: course, assignment: assignment, group: group) }

  before do
    allow(view).to receive_messages(
      current_course: course,
      # stub path called in partial app/views/submissions/_buttons.haml
      assignment_submission_path: "#",
      presenter: presenter
    )
    group.assignments << assignment
  end

  it "renders successfully for a group submission" do
    render
    assert_select "h3", text: "#{group.name}'s #{assignment.name} Submission (12,000 points)", count: 1
  end

  it "renders the submitted at date" do
    render
    assert_select "span.submission-date", text: "#{ submission.submitted_at }", count: 1
  end
end
