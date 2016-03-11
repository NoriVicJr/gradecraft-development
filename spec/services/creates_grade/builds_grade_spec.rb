require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/builds_grade"

describe Services::Actions::BuildsGrade do

  let(:world) { World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade, :badge) }
  let(:attributes) { RubricGradePUT.new(world).params }
  let(:context) {{
      attributes: attributes,
      student: world.student,
      assignment: world.assignment
    }}

  it "expects attributes to assign to grade" do
    context.delete(:attributes)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect student to be added to the context" do
    context.delete(:student)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect assignment to be added to the context" do
    context.delete(:assignment)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built grade" do
    result = described_class.execute context
    expect(result).to have_key :grade
  end

  it "adds attributes to the grade" do
    result = described_class.execute context
    expect(result[:grade].assignment_id).to eq world.assignment.id
    expect(result[:grade].student_id).to eq world.student.id
    expect(result[:grade].point_total).to eq attributes["points_possible"]
    expect(result[:grade].raw_score).to eq world.assignment.point_total - 10
    expect(result[:grade].status).to eq "Released"
    expect(result[:grade].feedback).to eq "good jorb!"
    expect(result[:grade].points_adjustment).to eq -10
    expect(result[:grade].points_adjustment_feedback).to eq "reduced by 10 points"
  end

  it "adds the group id if supplied" do
    context[:attributes]["group_id"] = 777
    result = described_class.execute context
    expect(result[:grade].group_id).to eq 777
  end
end
