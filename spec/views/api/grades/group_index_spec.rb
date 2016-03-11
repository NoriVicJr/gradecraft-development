# encoding: utf-8
require "rails_spec_helper"

describe "api/grades/group_index" do
  before(:all) do
    world = World.create.with(:course, :assignment, :student, :grade)

    # Expected instance variables on render:
    @grades = [create(:grade)]
    @student_ids = [1,2,3,4,5]
    @grades_status_options = ["In Progress","Graded", "Released"]
  end

  it "responds with an array of gradew" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["type"]).to eq("grades")
  end

  it "adds the attributes to the grade" do
    render
    json = JSON.parse(response.body)
    expect(json["data"][0]["attributes"]["id"]).to eq(@grades[0].id)
    expect(json["data"][0]["attributes"]["assignment_id"]).to eq(@grades[0].assignment_id)
    expect(json["data"][0]["attributes"]["student_id"]).to eq(@grades[0].student_id)
    expect(json["data"][0]["attributes"]["feedback"]).to eq(@grades[0].feedback)
    expect(json["data"][0]["attributes"]["status"]).to eq(@grades[0].status)
    expect(json["data"][0]["attributes"]["points_adjustment"]).to eq(@grades[0].points_adjustment)
    expect(json["data"][0]["attributes"]["points_adjustment_feedback"]).to eq(@grades[0].points_adjustment_feedback)
  end

  it "adds grading status options to meta data" do
    render
    json = JSON.parse(response.body)
    expect(json["meta"]["grade_status_options"]).to eq(@grade_status_options)
  end
end
