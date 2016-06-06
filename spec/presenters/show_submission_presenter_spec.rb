require 'active_record_spec_helper'
require "active_support/inflector"
require "./app/presenters/show_submission_presenter"

describe ShowSubmissionPresenter do
  # build a new presenter with some default properties
  subject { described_class.new properties }

  let(:properties) do
    { course: course }
  end

  let(:submission) { double(:submission, student: student, group: group, assignment: assignment, id: 200, submitted_at: Time.now) }
  let(:assignment) { double(:assignment, course: course, threshold_points: 13200, grade_scope: "Group", id: 300).as_null_object }
  let(:course) { double(:course, name: "Some Course").as_null_object }
  let(:student) { double(:user, first_name: "Jimmy", id: 500)}
  let(:group) { double(:group, name: "My group", course: course, id: 400) }
  let(:grade) { double(:grade).as_null_object }

  before(:each) do
    allow(subject).to receive_messages(
      student: student,
      group: group,
      assignment: assignment
    )
  end

  it "inherits from the Submission Presenter" do
    expect(described_class.superclass).to eq SubmissionPresenter
  end

  it "includes SubmissionGradeHistory" do
    expect(subject).to respond_to :submission_grade_filtered_history
  end

  describe "#individual_assignment?" do
    it "returns the output of assignment#is_individual?" do
      allow(subject.assignment).to receive(:is_individual?) { "stuff" }
      expect(subject.individual_assignment?).to eq "stuff"
    end
  end

  describe "#owner" do
    context "the submission is for an individual student assignment" do
      it "returns the student" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner).to eq student
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner).to eq group
      end
    end
  end

  describe "#owner_name" do
    context "the submission is for an individual student assignment" do
      it "returns the student's first name" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner_name).to eq student.first_name
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group name" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner_name).to eq group.name
      end
    end
  end

  describe "#grade" do
    let(:result) { subject.grade }
    let(:grades) { double(:grades).as_null_object }

    before(:each) do
      allow(assignment).to receive(:grades) { grades }
    end

    it "caches the grade" do
      result
      expect(grades).not_to receive(:find_by)
      result
    end

    context "the submission is for an individual student assignment" do
      it "finds the grade by student_id" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(grades).to receive(:find_by).with(student_id: student.id)
        result
      end
    end

    context "the submission is for a group assignment" do
      it "finds the grade by group_id" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(grades).to receive(:find_by).with(group_id: group.id)
        result
      end
    end
  end

  describe "#submission" do
    let(:result) { subject.submission }

    context "id exists and Submission.find returns a valid record" do
      before do
        allow(subject).to receive(:id) { 900 }
        allow(Submission).to receive(:find) { submission }
      end

      it "finds the submission by id" do
        expect(Submission).to receive(:find).with 900
        result
      end

      it "caches the submission" do
        result
        expect(Submission).not_to receive(:find).with(900)
        result
      end

      it "sets the submission to an ivar" do
        result
        expect(subject.instance_variable_get(:@submission)).to eq submission
      end
    end

    context "a non-existent id is passed to Submission.find" do
      it "rescues to nil" do
        allow(subject).to receive(:id) { 980_000 }
        expect(result).to eq nil
      end
    end

    context "a nil id is passed to Submission.find" do
      it "rescues to nil" do
        allow(subject).to receive(:id) { nil }
        expect(result).to eq nil
      end
    end

    context "an ActiveRecord::RecordNotFound error is raised" do
      it "rescues to nil" do
        allow(Submission).to receive(:find).and_raise ActiveRecord::RecordNotFound
        expect(result).to eq nil
      end
    end
  end

  describe "#student" do
    it "returns the student from the submission" do
      expect(subject.student).to eq submission.student
    end
  end

  describe "#submission_grade_history" do
    before do
      allow(subject).to receive_messages(
        submission: submission,
        grade: grade
      )
    end

    it "returns the submission grade history" do
      expect(subject).to receive(:submission_grade_filtered_history)
        .with(submission, grade, false)
      subject.submission_grade_history
    end
  end

  describe "#submitted_at" do
    it "returns the submitted_at date from the submission" do
      allow(subject).to receive(:submission) { submission }
      expect(subject.submitted_at).to eq submission.submitted_at
    end
  end

  describe "#open_for_editing?" do
    let(:result) { subject.open_for_editing? }

    before do
      allow(subject).to receive(:grade) { grade }
    end

    context "assignment is not open" do
      it "returns false" do
        allow(assignment).to receive(:open?) { false }
        expect(result).to eq false
      end
    end

    context "assignment is open" do
      context "grade is not present" do
        it "returns true" do
          allow(grade).to receive(:present?) { false }
          expect(result).to eq true
        end
      end

      context "grade is present but re-submissions are allowed" do
        it "returns true" do
          allow(grade).to receive(:present?) { true }
          allow(assignment).to receive(:resubmissions_allowed?) { true }
          expect(result).to eq true
        end
      end

      context "grades is not present and re-submissions are not allowed" do
        it "returns false" do
          allow(grade).to receive(:present?) { true }
          allow(assignment).to receive(:resubmissions_allowed?) { false }
          expect(result).to eq false
        end
      end
    end
  end

  describe "#title" do
    let(:assignment) { double(:assignment, name: "Greatness", point_total: 40) }
    let(:view_context) { double(:view_context).as_null_object }

    before do
      allow(subject).to receive(:owner_name) { "Gary" }
      allow(subject).to receive(:view_context) { view_context }
      allow(subject.view_context).to receive(:points).with(40) { 800 }
    end

    it "builds a title for the show submission page" do
      expect(subject.title)
        .to eq "Gary's Greatness Submission (800 points)"
    end
  end
end
