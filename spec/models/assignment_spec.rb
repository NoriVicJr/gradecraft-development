describe Assignment do
  subject { build(:assignment) }

  context "with a persisted assignment" do
    it_behaves_like "a model that needs sanitization", :assignment, :purpose
  end

  context "validations" do
    it "is valid with a name and assignment type" do
      expect(subject).to be_valid
    end

    it "is invalid without a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "is invalid without an assignment type" do
      subject.assignment_type_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:assignment_type_id]).to include "can't be blank"
    end

    it "is invalid with points greater than assignment type cap" do
      subject.assignment_type.update(max_points: 1000)
      subject.full_points = 2000
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "The full points for the assignment must be less than the cap for the whole assignment type."
    end

    it "is invalid without a course" do
      subject.course_id = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course_id]).to include "can't be blank"
    end

    it "is invalid without a grade scope" do
      subject.grade_scope = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:grade_scope]).to include "can't be blank"
    end

    it "is invalid without required status" do
      subject.required = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:required]).to include "must be true or false"
    end

    it "is invalid without accepts_submissions" do
      subject.accepts_submissions = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:accepts_submissions]).to include "must be true or false"
    end

    it "is invalid without student_logged" do
      subject.student_logged = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:student_logged]).to include "must be true or false"
    end

    it "is invalid without visible" do
      subject.visible = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible]).to include "must be true or false"
    end

    it "is invalid without resubmissions_allowed" do
      subject.resubmissions_allowed = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:resubmissions_allowed]).to include "must be true or false"
    end

    it "is invalid without use_rubric" do
      subject.use_rubric = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:use_rubric]).to include "must be true or false"
    end

    it "is invalid without accepts_attachments" do
      subject.accepts_attachments = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:accepts_attachments]).to include "must be true or false"
    end

    it "is invalid without accepts_text" do
      subject.accepts_text = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:accepts_text]).to include "must be true or false"
    end

    it "is invalid without accepts_links" do
      subject.accepts_links = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:accepts_links]).to include "must be true or false"
    end

    it "is invalid without pass_fail" do
      subject.pass_fail = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:pass_fail]).to include "must be true or false"
    end

    it "is invalid without hide_analytics" do
      subject.hide_analytics = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:hide_analytics]).to include "must be true or false"
    end

    it "is invalid without visible_when_locked" do
      subject.visible_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:visible_when_locked]).to include "must be true or false"
    end

    it "is invalid without show_name_when_locked" do
      subject.show_name_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_name_when_locked]).to include "must be true or false"
    end

    it "is invalid without show_points_when_locked" do
      subject.show_points_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_points_when_locked]).to include "must be true or false"
    end

    it "is invalid without show_description_when_locked" do
      subject.show_description_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_description_when_locked]).to include "must be true or false"
    end

    it "is invalid without threshold_points" do
      subject.threshold_points = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:threshold_points]).to include "can't be blank"
    end

    it "is invalid without show_purpose_when_locked" do
      subject.show_purpose_when_locked = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:show_purpose_when_locked]).to include "must be true or false"
    end

    it "is invalid if it is due before it is open" do
      subject.due_at = 2.days.from_now
      subject.open_at = 3.days.from_now
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "Close date must be after open date."
    end

    it "is invalid if accepting submissions before it is open" do
      subject.open_at = 2.days.from_now
      subject.accepts_submissions_until = 1.day.from_now
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "Submission accept date must be after open date."
    end

    it "is invalid accepting submissions before it is due" do
      subject.due_at = 2.days.from_now
      subject.accepts_submissions_until = 1.day.from_now
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "Submission accept date must be after due date."
    end

    it "requires a numeric for max group size" do
      subject.max_group_size = "a"
      expect(subject).to_not be_valid
      expect(subject.errors[:max_group_size]).to include "is not a number"
    end

    it "allows for a nil max group size" do
      subject.max_group_size = nil
      expect(subject).to be_valid
      expect(subject.errors[:max_group_size]).to be_empty
    end

    it "requires the max group size to be greater than 0" do
      subject.max_group_size = 0
      expect(subject).to_not be_valid
      expect(subject.errors[:max_group_size]).to include "must be greater than or equal to 1"
    end

    it "requires a numeric for min group size" do
      subject.min_group_size = "a"
      expect(subject).to_not be_valid
      expect(subject.errors[:min_group_size]).to include "is not a number"
    end

    it "allows for a nil min group size" do
      subject.min_group_size = nil
      expect(subject).to be_valid
      expect(subject.errors[:min_group_size]).to be_empty
    end

    it "verifies that max group size is greater than min group size" do
      subject.max_group_size = 1
      subject.min_group_size = 3
      expect(subject).to_not be_valid
      expect(subject.errors[:base]).to include "Maximum group size must be greater than minimum group size."
    end
  end

  describe "position" do
    it "sets the position by assignment type on save (using acts_as_list gem)" do
      expect(subject.position).to be_nil
      subject.save
      expect(subject.position).to be(1)
      a2 = create :assignment
      expect(a2.position).to be(1)
      a3 = create :assignment, assignment_type: a2.assignment_type
      expect(a3.position).to be(2)
    end
  end

  describe "#min_group_size" do
    it "sets the default min group size at 2" do
      expect(subject.min_group_size).to eq(1)
    end

    it "accepts the instructor's setting here if it exists" do
      subject.min_group_size = 3
      expect(subject.min_group_size).to eq(3)
    end
  end

  describe "#max_group_size" do
    it "sets the default max group size at 6" do
      expect(subject.max_group_size).to eq(5)
    end

    it "accepts the instructor's setting here if it exists" do
      subject.max_group_size = 8
      expect(subject.max_group_size).to eq(8)
    end
  end

  describe "#max_more_than_min" do
    it "errors out if the max group size is smaller than the minimum" do
      subject.max_group_size = 2
      subject.min_group_size = 5
      expect !subject.valid?
    end
  end

  describe "#assignment_files_attributes=" do
    it "supports multiple file uploads" do
      file_attribute_1 = fixture_file "test_file.txt", "txt"
      file_attribute_2 = fixture_file "test_image.jpg", "image/jpg"
      subject.assignment_files_attributes = { "0" => { "file" => [file_attribute_1, file_attribute_2] }}
      expect(subject.assignment_files.length).to eq 2
      expect(subject.assignment_files[0].filename).to eq "test_file.txt"
      expect(subject.assignment_files[1].filename).to eq "test_image.jpg"
    end
  end

  describe "#find_or_create_rubric" do
    it "returns a rubric if one exists" do
      rubric = create(:rubric, assignment: subject)
      expect(subject.find_or_create_rubric).to eq(rubric)
    end

    it "creates a rubric if one does not exist" do
      assignment = create(:assignment)
      new_rubric = assignment.find_or_create_rubric
      expect(new_rubric).to eq assignment.reload.rubric
    end
  end

  describe "pass-fail assignments" do
    it "sets point total to zero on save" do
      subject.full_points = 3000
      subject.threshold_points = 2000
      subject.pass_fail = true
      subject.save
      expect(subject.full_points).to eq(0)
      expect(subject.threshold_points).to eq(0)
    end
  end

  describe "#copy" do
    let(:assignment) { build_stubbed :assignment, position: 0 }
    subject { assignment.copy }

    it "preserves the original assignment name" do
      assignment.name = "Table of elements"
      expect(subject.name).to eq "Table of elements"
    end
  end

  describe "#copy_with_prepended_name" do
    let(:assignment) { build :assignment }
    subject { assignment.copy_with_prepended_name }

    it "prepends the name with 'Copy of'" do
      assignment.name = "Table of elements"
      expect(subject.name).to eq "Copy of Table of elements"
    end

    it "makes a shallow copy of the fields" do
      assignment.description = "This is a great assignment"
      expect(subject.description).to eq "This is a great assignment"
    end

    it "saves the copy if the assignment is saved" do
      assignment.save
      expect(subject).to_not be_new_record
    end

    it "copies the assignment score levels" do
      assignment.save
      assignment.assignment_score_levels.create
      expect(subject.assignment_score_levels.size).to eq 1
      expect(subject.assignment_score_levels.map(&:assignment_id)).to eq [subject.id]
    end

    it "copies the rubric" do
      assignment.save
      assignment.build_rubric(course_id: assignment.course_id)
      expect(subject.rubric.assignment_id).to eq subject.id
      expect(subject.rubric).to_not be_new_record
    end

    describe "copies on a new course" do
      let(:assignment) {create :assignment}

      it "copies the course id onto copied assignments" do
        assignment.create_rubric(course_id: assignment.course_id)
        course_copy = assignment.course.copy(nil)
        assignment_copy = course_copy.assignments.first
        expect(assignment.course_id).to_not eq(assignment_copy.course_id)
        expect(course_copy.assignments.first.rubric.course_id).to eq(course_copy.assignments.first.course_id)
      end
    end
  end

  describe "#future?" do
    it "is not for the future if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_future
    end

    it "is not for the future if the due date is in the past" do
      subject.due_at = 2.days.ago
      expect(subject).to_not be_future
    end

    it "is for the future if the due date is in the future" do
      subject.due_at = 2.days.from_now
      expect(subject).to be_future
    end
  end

  describe "#grade_for_student" do
    let(:student) { create :user }
    before { subject.save }

    it "returns the first visible grade for the student" do
      grade = subject.grades.create student_id: student.id, raw_points: 85, student_visible: true
      expect(subject.grade_for_student(student)).to eq grade
    end
  end

  describe "#grade_level" do
    it "returns the assignment score level for the grade's score" do
      grade = build(:grade, final_points: 123)
      subject.assignment_score_levels.build name: "First level", points: 123
      expect(subject.grade_level(grade)).to eq "First level"
    end

    it "returns nil if there is no assignment score level found" do
      grade = build(:grade, final_points: 123)
      subject.assignment_score_levels.build name: "First level", points: 456
      expect(subject.grade_level(grade)).to be_nil
    end
  end

  describe "#has_levels?" do
    it "has levels if there are assignment score levels" do
      subject.assignment_score_levels.build
      expect(subject).to have_levels
    end
  end

  describe "#grade_with_rubric?" do
    it "is true if all required conditions are met" do
      assignment = create(:assignment)
      assignment.create_rubric
      allow(assignment.rubric).to receive(:designed?).and_return true
      expect(assignment.grade_with_rubric?).to be_truthy
    end

    it "is false if the rubric is not designed" do
      assignment = create(:assignment)
      assignment.create_rubric
      expect(assignment.grade_with_rubric?).to be_falsey
    end
  end

  describe "#is_predicted_by_student?" do
    let(:student) { create :user }
    before { subject.save }

    it "returns true if the student has a predicted earned grade" do
      subject.predicted_earned_grades.create student_id: student.id, predicted_points: 83
      expect(subject.is_predicted_by_student?(student)).to eq true
    end

    it "returns false if there are no grades for the student" do
      expect(subject.is_predicted_by_student?(student)).to eq false
    end
  end

  describe "#has_submitted_submissions?" do
    let!(:draft_submission) { create(:draft_submission, assignment: subject) }

    context "when there are submitted submissions" do
      let!(:submitted_submission) { create(:submission, assignment: subject) }

      it "returns true" do
        expect(subject.has_submitted_submissions?).to eq true
      end
    end

    context "when there are no submitted submissions" do
      it "returns false" do
        expect(subject.has_submitted_submissions?).to eq false
      end
    end
  end

  describe "#soon?" do
    it "is not soon if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_soon
    end

    it "is not soon if the due date is too far in the future" do
      subject.due_at = 8.days.from_now
      expect(subject).to_not be_soon
    end

    it "is soon if the due date is within 7 days from now" do
      subject.due_at = 2.days.from_now
      expect(subject).to be_soon
    end
  end

  describe "#opened?" do
    it "is opened if there is no open at date set" do
      subject.open_at = nil
      expect(subject).to be_opened
    end

    it "is opened if the open at date is in the past" do
      subject.open_at = 2.days.ago
      expect(subject).to be_opened
    end

    it "is not opened if the assignment opens in the future" do
      subject.open_at = 2.days.from_now
      expect(subject).to_not be_opened
    end
  end

  describe "#overdue" do
    it "is not overdue if there is no due date" do
      subject.due_at = nil
      expect(subject).to_not be_overdue
    end

    it "is not overdue if the due date is in the future" do
      subject.due_at = 2.days.from_now
      expect(subject).to_not be_overdue
    end

    it "is overdue if the due date has past" do
      subject.due_at = 2.days.ago
      expect(subject).to be_overdue
    end
  end

  describe "#accepting_submissions?" do
    it "is accepting submissions if no acceptance date was set" do
      subject.accepts_submissions_until = nil
      expect(subject).to be_accepting_submissions
    end

    it "is accepting submissions if the acceptance date is in the future" do
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_accepting_submissions
    end

    it "is not accepting submissions if the acceptance date was in the past" do
      subject.accepts_submissions_until = 2.days.ago
      expect(subject).to_not be_accepting_submissions
    end
  end

  describe "#submissions_have_closed?" do
    it "is true if the assignment no longer accepts submissions" do
      subject.accepts_submissions_until = 2.days.ago
      expect(subject.submissions_have_closed?).to be_truthy
    end

    it "is false if assignment accepts submisions currently or in the future" do
      subject.accepts_submissions_until = nil
      expect(subject.submissions_have_closed?).to_not be_truthy
    end

    it "is false if assignment never accepts submissions" do
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject.submissions_have_closed?).to_not be_truthy
    end
  end

  describe "#open?" do
    before do
      subject.open_at = 4.days.ago
      subject.due_at = 2.days.ago
      subject.accepts_submissions_until = 2.days.ago
    end

    it "is open if there is no open date and there is no due date" do
      subject.open_at = nil
      subject.due_at = nil
      expect(subject).to be_open
    end

    it "is open if the open date has passed but there is no due date" do
      subject.due_at = nil
      expect(subject).to be_open
    end

    it "is open if there is no open date but there is a future due date" do
      subject.open_at = nil
      subject.due_at = 2.days.from_now
      expect(subject).to be_open
    end

    it "is open if there is no open date, the due date has passed and it does not have an accept date" do
      subject.open_at = nil
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is no open date, the due date has passed and it has a future accept date" do
      subject.open_at = nil
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_open
    end

    it "is open if there is a previous open date, a future due date and it does not have an accept date" do
      subject.open_at = nil
      subject.due_at = 2.days.from_now
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is a previous open date, a previous due date and it does not have an accept date" do
      subject.accepts_submissions_until = nil
      expect(subject).to be_open
    end

    it "is open if there is a previous open date and a future accept date" do
      subject.accepts_submissions_until = 2.days.from_now
      expect(subject).to be_open
    end
  end

  describe "#to_json" do
    it "returns a json representation" do
      json = subject.to_json
      expect(json).to eq({ id: subject.id }.to_json)
    end
  end
end
