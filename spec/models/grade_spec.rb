require "active_record_spec_helper"
require "toolkits/historical_toolkit"
require "toolkits/sanitization_toolkit"

describe Grade do
  subject { build(:grade) }

  describe "validations" do
    it "is valid with an assignment, student, assignment_type, and course" do
      expect(subject).to be_valid
    end

    it "is invalid without an assignment" do
      subject.assignment = nil
      expect{ subject.save! }.to raise_error Module::DelegationError
    end

    it "is invalid without a student" do
      subject.student = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:student]).to include "can't be blank"
    end

    it "is invalid without a course" do
      subject.assignment.course = nil
      subject.course = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course]).to include "can't be blank"
    end

    it "is invalid without an assignment type" do
      subject.assignment.assignment_type = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment_type]).to include "can't be blank"
    end

    it "does not allow duplicate grades per student" do
      subject.save!
      another_grade = build(:grade, course: subject.course, assignment: subject.assignment, student: subject.student)
      expect(another_grade).to_not be_valid
      expect(another_grade.errors[:assignment_id]).to include "has already been taken"
    end
  end

  it_behaves_like "a historical model", :grade, raw_score: 1234
  it_behaves_like "a model that needs sanitization", :feedback

  describe "versioning", versioning: true do
    it "ignores changes to predicted_score" do
      subject.save!
      subject.update_attributes predicted_score: 12000
      expect(subject.versions.count).to eq 1
      expect(subject.versions.first.event).to eq "create"
    end
  end

  describe "#raw_score" do
    it "converts raw_score from human readable strings" do
      subject.update(raw_score: "1,234")
      expect(subject.raw_score).to eq(1234)
    end
  end

  describe "when assignment is pass-fail" do
    before do
      subject.assignment.update(pass_fail: true)
    end

    it "saves the grades as zero" do
      subject.save!
      expect(subject.raw_score).to be 0
      expect(subject.predicted_score).to be <= 1
      expect(subject.final_score).to be 0
      expect(subject.point_total).to be 0
    end
  end

  describe "#feedback_read!" do
    it "marks the grade as read" do
      subject.feedback_read!
      expect(subject).to be_feedback_read
      elapsed = ((DateTime.now - subject.feedback_read_at.to_datetime) * 24 * 60 * 60).to_i
      expect(elapsed).to be < 5
    end
  end

  describe "#feedback_reviewed!" do
    it "marks the grade as reviewed" do
      subject.feedback_reviewed!
      expect(subject).to be_feedback_reviewed
      elapsed = ((DateTime.now - subject.feedback_reviewed_at.to_datetime) * 24 * 60 * 60).to_i
      expect(elapsed).to be < 5
    end
  end

  describe ".for_course" do
    it "returns all grades for a specific course" do
      course = create(:course)
      course_grade = create(:grade, course: course)
      another_grade = create(:grade)
      results = Grade.for_course(course)
      expect(results).to eq [course_grade]
    end
  end

  describe ".for_student" do
    it "returns all grades for a specific student" do
      student = create(:user)
      student_grade = create(:grade, student: student)
      another_grade = create(:grade)
      results = Grade.for_student(student)
      expect(results).to eq [student_grade]
    end
  end

  describe ".find_or_create" do
    it "finds and existing grade for assignment and student" do
      world = World.create.with(:course, :student, :assignment, :grade)
      results = Grade.find_or_create(world.assignment.id,world.student.id)
      expect(results).to eq world.grade
    end

    it "creates a grade for assignment and student if none exists" do
      world = World.create.with(:course, :student, :assignment)
      expect{Grade.find_or_create(world.assignment.id,world.student.id)}.to \
        change{ Grade.count }.by(1)
    end
  end

  describe ".find_or_create_grades" do
    let(:world) { World.create.with(:course, :group, :assignment) }
    let(:ids) { world.group.students.pluck(:id) }

    it "finds and existing grade for assignment and student" do
      results = Grade.find_or_create_grades(world.assignment.id, ids)
      expect(results.count).to eq ids.length
    end

    it "creates a grade for assignment and student if none exists" do
      expect { Grade.find_or_create_grades(world.assignment.id, ids) }.to \
        change{ Grade.count }.by(ids.length)
    end
  end

  describe "#add_grade_files" do
    it "adds a file from upload" do
      student = create(:user)
      assignment = create(:assignment)
      grade = create(:grade, student: student, assignment: assignment)
      grade_file = fixture_file('Too long, strange characters, and Spaces (In) Name.jpg', 'img/jpg')
      grade.add_grade_files(grade_file)
      expect(grade.grade_files.count).to eq(1)
    end
  end
end
