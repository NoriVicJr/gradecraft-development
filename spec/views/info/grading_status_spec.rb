# encoding: utf-8
require "rails_spec_helper"

describe "info/grading_status" do

  before(:each) do
    @title = "Unspecified Title"
    @course = create(:course)
    @team = create(:team, course: @course)
    @assignment_types = [create(:assignment_type, course: @course, max_points: 1000)]
    @assignment = create(:assignment, assignment_type: @assignment_types[0])
    @student = create(:user)
    assign(:assignment_types, @assignment_types)
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:term_for).and_return("custom_term")
  end

  describe "with ungraded submissions" do
    before(:each) do
      @grades = [create(:grade, course: @course, assignment: @assignment, student: @student)]
      ungraded_submission = create(:submission, student: @student, assignment: @assignment)
      @ungraded_submissions_by_assignment = [ungraded_submission].group_by(&:assignment)
      @unreleased_grades_by_assignment = []
      @in_progress_grades_by_assignment = []
      @resubmissions_by_assignment = []
    end
    it "renders successfully" do
      render
    end
  end

  describe "with unreleased grades" do
    before(:each) do
      @grades = [create(:unreleased_grade, course: @course, assignment: @assignment, student: @student)]
      @ungraded_submissions_by_assignment = []
      @unreleased_grades_by_assignment = @grades.group_by(&:assignment)
      @in_progress_grades_by_assignment = []
      @resubmissions_by_assignment = []
    end
    it "renders successfully" do
      render
    end
  end

  describe "with in progress grades"  do
    before(:each) do
      @grades = [create(:in_progress_grade, course: @course, assignment: @assignment, student: @student)]
      @ungraded_submissions_by_assignment = []
      @unreleased_grades_by_assignment = []
      @in_progress_grades_by_assignment = @grades.group_by(&:assignment)
      @resubmissions_by_assignment = []
    end
    it "renders successfully" do
      render
    end
  end

  describe "with resubmissions"  do
    before(:each) do
      resubmission = create(:submission, student: @student, assignment: @assignment)
      @ungraded_submissions_by_assignment = []
      @unreleased_grades_by_assignment = []
      @in_progress_grades_by_assignment = []
      @resubmissions_by_assignment = [resubmission].group_by(&:assignment)
    end
    it "renders successfully" do
      render
    end
  end
end
