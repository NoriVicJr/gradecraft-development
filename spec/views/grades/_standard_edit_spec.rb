# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "grades/_standard_edit" do

  before(:each) do
    @course = create(:course)
    @assignment = create(:assignment)
    @course.assignments << @assignment
    @student = create(:user)
    @student.courses << @course
    @grade = create(:grade, course: @course, assignment: @assignment, student: @student)
    @assignment_score_levels = [] # add this so the view doesn't crash
    allow(view).to receive(:current_student).and_return(@student)
    current_user = double
    allow(current_user).to receive(:id) {0}
    allow(view).to receive(:grade).and_return(@grade)
    allow(view).to receive(:submission).and_return(nil)
    allow(view).to receive(:current_user).and_return(current_user)
    allow(view).to receive(:current_course).and_return(@course)
  end

  describe "when an assignment has point values" do
    it "renders the points possible when incomplete" do
      render
      assert_select "label", text: "Raw Points (#{points @assignment.full_points} Points Possible)", count: 1
    end
  end

  describe "when an assignment is pass fail", skip: true do
    before(:each) do
      @assignment.update(pass_fail: true)
    end

    it "renders Pass/Fail in the points possible field when incomplete" do
      render
      assert_select "label", text: "Raw Points (0 Points Possible)", count: 0
      assert_select "label", text: "Pass fail status", count: 1
    end

    it "renders the switch in the fail position when not yet graded" do
      render
      assert_select ".switch-label", text: "Fail", count: 1
    end

    it "renders the switch in the pass position when grade status is 'Pass'" do
      @grade.update(pass_fail_status: "Pass")
      render
      assert_select ".switch-label", text: "Pass", count: 1
      assert_select ".switch" do
        assert_select "#grade_pass_fail_status[value=Pass]", count: 1
      end
    end

    it "renders the switch in the fail position when the grade is 'Fail'" do
      @grade.update(pass_fail_status: "Fail")
      render
      assert_select ".switch-label", text: "Fail", count: 1
    end

    it "uses the course term for Fail when present" do
      @course.update(fail_term: "No Pass For You!")
      render
      assert_select ".switch-label", text: "No Pass For You!", count: 1
    end

    it "uses the course term for Pass when present" do
      @course.update(pass_term: "Pwned")
      @grade.update(pass_fail_status: "Pass")
      render
      assert_select ".switch-label", text: "Pwned", count: 1
    end
  end
end
