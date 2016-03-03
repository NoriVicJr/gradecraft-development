# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "students/teams" do

  before(:all) do
    @course = create(:course)
    @student = create(:user)
    @student.courses << @course
    @membership = CourseMembership.where(user: @student, course: @course).first.update(score: "100000")
  end

  before(:each) do
    allow(view).to receive(:current_course).and_return(@course)
    allow(view).to receive(:current_student).and_return(@student)
  end

  it "renders successfully" do
    render
    assert_select "h3", count: 1
  end

end
