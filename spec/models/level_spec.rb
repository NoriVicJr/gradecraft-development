describe Level do
  let(:level) { create :level }
  subject { level }

  describe "sort order" do
    let(:level_1) { create :level, points: 100, sort_order: 2 }
    let(:level_2) { create :level, points: 1, sort_order: 3 }
    let(:level_3) { create :level, points: 100, sort_order: 1 }
    let(:criterion) { create :criterion }

    before do
      criterion.levels.destroy_all
      criterion.levels << [level_1,level_2,level_3]
    end

    it "orders by points" do
      expect(criterion.levels.ordered.first).to eq(level_2)
    end

    it "sorts by sort_order" do
      expect(criterion.levels.sorted).to eq([level_3,level_1,level_2])
    end

    it "can be scoped to order by points, and secondarily by sort_order" do
      expect(criterion.levels.ordered.sorted).to eq([level_2,level_3,level_1])
    end
  end

  it "is invalid with negative points" do
    subject.points = -100
    expect(subject).to_not be_valid
  end

  describe "#above_expectations?" do
    it "is false if points are equal to or below expectations" do
      subject.criterion.update(meets_expectations_points: subject.points)
      expect(subject.above_expectations?).to be_falsey
    end

    it "is true if points are above expectations" do
      allow(subject.criterion).to \
        receive(:meets_expectations_level_id).and_return("not nil")
      subject.criterion.update(
        meets_expectations_points: (subject.points - 1)
      )
      expect(subject.above_expectations?).to be_truthy
    end
  end

  describe "#copy" do
    it "duplicates the level badges for the level" do
      level_badge = create :level_badge
      level = level_badge.level
      subject = level.copy
      expect(subject.level_badges.size).to eq 1
      expect(subject.level_badges.pluck(:badge_id)).to eq \
        level.level_badges.pluck(:badge_id)
      expect(LevelBadge.count).to eq(2)
    end
  end

  describe "updating points" do
    it "updates the meets exectations points on criterion" do
      level.save
      level.criterion.update_meets_expectations!(level, true)
      level.update(points: 10)
      expect(level.criterion.reload.meets_expectations_points).to eq(10)
    end
  end

  describe "#earned_by?" do
    let!(:criterion_grade) { create :criterion_grade, level: subject,
                             student: student }
    let(:student) { create :user }
    subject { create :level }

    it "is earned if a criterion grade exists for the student" do
      expect(subject).to be_earned_for student.id
    end

    it "is not earned if a criterion grade does not exist for the student" do
      expect(subject).to_not be_earned_for 12345
    end
  end

  describe "#hide_analytics?" do
    let(:rubric) { build :rubric }
    let(:criterion) { build :criterion, rubric: rubric }
    subject { build :level, criterion: criterion }

    it "is hidden if the course and assignment are set to hide analytics" do
      rubric.assignment.hide_analytics = true
      rubric.assignment.course.show_analytics = false
      expect(subject.hide_analytics?).to eq true
    end

    it "is hidden if the assignment is set to hide analytics" do
      rubric.assignment.hide_analytics = true
      rubric.assignment.course.show_analytics = true
      expect(subject.hide_analytics?).to eq true
    end

    it "is hidden if the course is set to hide analytics" do
      rubric.assignment.hide_analytics = false
      rubric.assignment.course.show_analytics = false
      expect(subject.hide_analytics?).to eq true
    end
  end
end
