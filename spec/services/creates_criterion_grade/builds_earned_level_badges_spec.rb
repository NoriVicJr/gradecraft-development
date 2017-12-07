describe Services::Actions::BuildsEarnedLevelBadges do
  let(:course) { create :course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:professor) { create(:course_membership, :professor, course: course).user }
  let(:assignment) { create(:assignment, course: course) }
  let(:rubric) { create(:rubric, assignment: assignment) }
  let(:criterion) { create(:criterion, rubric: rubric) }
  let(:criterion_grade) { create(:criterion_grade, criterion: criterion) }
  let(:criterion_grade_2) { create(:criterion_grade, criterion: criterion) }
  let(:badge) { create(:badge, course: course) }
  let(:group) { create(:group, course: course, assignments: [assignment]) }
  let(:grade) { create(:grade, student: student, assignment: assignment) }

  let!(:level_badge) { create :dummy_level_badge, level: criterion_grade.level, badge: badge }

  let(:context) do
    {
      student: student,
      assignment: assignment,
      criterion_grades: criterion.criterion_grades,
      grade: grade,
      graded_by_id: professor.id
    }
  end
  it "expects attributes to assign to student" do
    context.delete(:student)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to criterion grades" do
    context.delete(:criterion_grades)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to grade" do
    context.delete(:grade)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to awarded_by_id" do
    context.delete(:graded_by_id)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built earned level badges" do
    result = described_class.execute context
    expect(result).to have_key :earned_level_badges
  end

  it "assigns level badges to the student for earned levels" do
    result = described_class.execute context
    expect(student.earned_badges.count).to eq(1)
  end

  it "assigns the earned badge awarded_by_id" do
    result = described_class.execute context
    expect(student.earned_badges.first.awarded_by_id).to eq(professor.id)
  end
end
