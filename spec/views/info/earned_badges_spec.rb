# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "info/earned_badges" do

  before(:all) do
    @course = create(:course)
    @student_1 = create(:user)
    @student_2 = create(:user)
    @course.students << [@student_1, @student_2]
    @students = @course.students

    @badge_1 = create(:badge, course: @course)
    @badge_2 = create(:badge, course: @course)
    @course.badges << [@badge_1, @badge_2]
    @badges = @course.badges
  end

  before(:each) do
    assign(:title, "Awarded Badges")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h2", text: "Awarded Badges", count: 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", count: 1
    assert_select ".breadcrumbs" do
      assert_select "a", count: 2
    end
  end
end
