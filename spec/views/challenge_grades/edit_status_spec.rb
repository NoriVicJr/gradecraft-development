# encoding: utf-8
require "rails_spec_helper"
include CourseTerms

describe "challenge_grades/edit_status" do

  before(:all) do
    @course = create(:course)
    @challenge = create(:challenge, course: @course)

    @team_1 = create(:team, course: @course)
    @team_2 = create(:team, course: @course)

    @challenge_grade_1 = create(:challenge_grade, challenge: @challenge, team: @team_1)
    @challenge_grade_2 = create(:challenge_grade, challenge: @challenge, team: @team_2)

    @challenge.challenge_grades << [ @challenge_grade_1, @challenge_grade_2 ]
    @challenge_grades = @course.challenge_grades

    @course.teams << [ @team_1, @team_2]
    @teams = @course.teams
  end

  before(:each) do
    assign(:title, "Editing Challenge Grade")
    allow(view).to receive(:current_course).and_return(@course)
  end

  it "renders successfully" do
    render
    assert_select "h3", text: "Editing Challenge Grade", :count => 1
  end

  it "renders the breadcrumbs" do
    render
    assert_select ".content-nav", :count => 1
    assert_select ".breadcrumbs" do
      assert_select "a", :count => 4
    end
  end
end
