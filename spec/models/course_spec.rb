describe Course do
  subject { build(:course) }
  let(:staff_membership) { create :course_membership, :staff, course: subject,
                                  instructor_of_record: true }

  describe "validations" do
    it "requires a name" do
      subject.name = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:name]).to include "can't be blank"
    end

    it "requires a course number" do
      subject.course_number = nil
      expect(subject).to_not be_valid
      expect(subject.errors[:course_number]).to include "can't be blank"
    end

    it "permit only allowed values for the learning objective term" do
      expect{ subject.learning_objective_term = :task }.to raise_error \
        ArgumentError, "'task' is not a valid learning_objective_term"
    end
  end

  describe "#copy" do
    let(:course) { create :course }
    subject { course.copy nil }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq course
    end

    it "prepends the name with 'Copy of'" do
      course.name = "Important Course"
      expect(subject.name).to eq "Copy of Important Course"
    end

    it "saves the copy if the course is saved" do
      expect(subject).to_not be_new_record
    end

    it "copies the badges" do
      create :badge, course: course
      expect(subject.badges.size).to eq 1
      expect(subject.badges.map(&:course_id)).to eq [subject.id]
    end

    it "copies the assignment types" do
      assignment_type = create :assignment_type, course: course
      create :assignment, assignment_type: assignment_type
      expect(subject.assignment_types.size).to eq 1
      expect(subject.assignment_types.map(&:course_id)).to eq [subject.id]
      expect(subject.assignments.map(&:course_id)).to eq [subject.id]
    end

    it "copies the challenges" do
      create :challenge, course: course
      expect(subject.challenges.size).to eq 1
      expect(subject.challenges.map(&:course_id)).to eq [subject.id]
    end

    it "copies the grade scheme elements" do
      create :grade_scheme_element, course: course
      expect(subject.grade_scheme_elements.size).to eq 1
      expect(subject.grade_scheme_elements.map(&:course_id)).to eq [subject.id]
    end

    it "overrides the specified attributes" do
      attributes = { tagline: "Behold, the greatest course of all!" }
      subject = course.copy nil, attributes
      expect(subject.tagline).to eq attributes[:tagline]
    end

    it "resets the lti uid to nil" do
      course = build_stubbed :course, lti_uid: "test_uid"
      duplicated = course.copy nil
      expect(duplicated.lti_uid).to be_nil
    end
  end

  describe "#copy with students" do
    let!(:student) { create(:course_membership, :student, course: subject).user }
    subject { create :course }

    it "turns off the create_admin_memberships callback" do
      expect_any_instance_of(Course).to_not receive(:create_admin_memberships)
      subject.copy "with_students"
    end

    it "turns back on the create_admin_memberships callback" do
      subject.copy "with_students"
      expect(Course._create_callbacks.map(&:filter)).to include :create_admin_memberships
    end

    it "copies the students" do
      duplicated = subject.copy "with_students"
      expect(duplicated.reload.users).to include student
    end

    it "copies the teams" do
      team = create :team, course: subject
      duplicated = subject.copy "with_students"
      expect(duplicated.teams.size).to eq 1
      expect(duplicated.teams.map(&:course_id)).to eq [duplicated.id]
    end

    it "overrides the specified attributes" do
      attributes = { tagline: "This course will blow your mind!" }
      duplicated = subject.copy "with_students", attributes
      expect(duplicated.tagline).to eq attributes[:tagline]
    end

    it "resets the lti uid to nil" do
      subject = build_stubbed :course, lti_uid: "test_uid"
      duplicated = subject.copy "with_students"
      expect(duplicated.lti_uid).to be_nil
    end
  end

  describe "#grade_scheme_elements" do
    let!(:high) { create(:grade_scheme_element, lowest_points: 2001, course: subject) }
    let!(:low) { create(:grade_scheme_element, lowest_points: 100, course: subject) }
    let!(:middle) { create(:grade_scheme_element, lowest_points: 1001, course: subject) }

    describe "#for_score" do
      it "returns the grade scheme element that falls within that points range" do
        result = subject.grade_scheme_elements.for_score(1100)

        expect(result).to eq middle
      end

      it "returns the highest grade scheme if the score if greater than the highest" do
        result = subject.grade_scheme_elements.for_score(3001)

        expect(result).to eq high
      end

      it "returns a new grade scheme if the score is lower that the lowest" do
        result = subject.grade_scheme_elements.for_score(99)

        expect(result.level).to eq "Not yet on board"
      end

      it "handles no grade scheme elements" do
        subject.grade_scheme_elements.delete_all

        result = subject.grade_scheme_elements.for_score(99)

        expect(result).to be_nil
      end

      it "does not include other courses" do
        another_course = create :course
        create :grade_scheme_element, lowest_points: 0, course: another_course

        result = subject.grade_scheme_elements.for_score(99)

        expect(result.id).to be_nil
      end
    end
  end

  describe "#linked?" do
    let(:provider) { :canvas }
    subject { create :course }

    it "is linked if it has a linked course to the specified provider" do
      LinkedCourse.create provider: provider, course_id: subject.id

      expect(subject).to be_linked provider
    end

    it "is not linked if it does not have a linked course for the specified provider" do
      expect(subject).to_not be_linked provider
    end
  end

  describe "#linked_for" do
    let!(:linked_course) { LinkedCourse.create provider: provider, course_id: subject.id }
    let(:provider) { :canvas }
    subject { create :course }

    it "returns the linked course for the specified provider" do
      expect(subject.linked_for(provider)).to eq linked_course
    end
  end

  describe "#staff" do
    it "returns a list of the staff in the course" do
      course = create(:course)
      staff_1 = create(:user, courses: [course], role: :gsi)
      staff_2 = create(:user, courses: [course], role: :gsi)
      staff_3 = create(:user)
      expect(course.staff).to match_array([staff_2,staff_1])
    end
  end

  describe "#students_being_graded" do
    it "returns a list of students being graded" do
      student = create(:user, courses: [subject], role: :student)
      student2 = create(:user, courses: [subject], role: :student)
      expect(subject.students_being_graded).to match_array([student2,student])
    end
  end

  describe "#students_being_graded_by_team(team)" do
    it "returns a list of students being graded for a specific team" do
      student = create(:user, courses: [subject], role: :student)
      student2 = create(:user, courses: [subject], role: :student)
      student3 = create(:user, courses: [subject], role: :student)
      team = create(:team, course: subject)
      team.students << [ student, student2]
      expect(subject.students_being_graded_by_team(team)).to match_array([student2,student])
    end
  end

  describe "#students_by_team(team)" do
    it "return a list of all students in a team" do
      student = create(:user)
      course_membership = create(:course_membership, :auditing, :student, user: student, course: subject)
      student2 = create(:user, courses: [subject], role: :student)
      student3 = create(:user)
      course_membership_2 = create(:course_membership, :auditing, :student, user: student3, course: subject)
      team = create(:team, course: subject)
      team.students << [student, student2]
      expect(subject.students_by_team(team)).to match_array([student2, student])
    end
  end

  it "returns Pass and Fail as defaults for pass_term and fail_term" do
    expect(subject.pass_term).to eq("Pass")
    expect(subject.fail_term).to eq("Fail")
  end

  describe ".active" do
    it "returns courses that have a status" do
      Course.destroy_all
      active = create :course, status: true
      inactive = create :course, status: false
      expect(Course.active.to_a).to eq [active]
    end
  end

  describe ".inactive" do
    it "returns courses that do not have a status" do
      Course.destroy_all
      active = create :course, status: true
      inactive = create :course, status: false
      expect(Course.inactive.to_a).to eq [inactive]
    end
  end

  describe "#instructors_of_record" do
    it "returns all the staff who are instructors of record for the course" do
      membership = staff_membership
      expect(subject.instructors_of_record).to eq [membership.user]
    end
  end

  describe "#instructors_of_record_ids=" do
    it "adds the instructors of record if they were not there before" do
      membership = create :course_membership, :staff, course: subject
      subject.instructors_of_record_ids = [membership.user_id]
      expect(subject.instructors_of_record).to eq [membership.user]
    end

    it "removes the instructors of record that are not present" do
      membership = staff_membership
      subject.instructors_of_record_ids = []
      expect(subject.instructors_of_record).to be_empty
    end
  end

  it "automatically assigns memberships to admins after the course is created" do
    admin = create :user, admin: true
    course = create :course
    expect(CourseMembership.where(user_id: admin.id, course_id: course.id, role: "admin")).to be_exist
  end

  describe "#assignment_term" do
    it "returns the set assignment_term if present" do
      subject.assignment_term = "Quest"
      expect(subject.assignment_term).to eq("Quest")
    end

    it "returns Assignment if no assignment_term is present" do
      expect(subject.assignment_term).to eq("Assignment")
    end
  end

  describe "#badge_term" do
    it "returns the set badge_term if present" do
      subject.badge_term = "Achievement"
      expect(subject.badge_term).to eq("Achievement")
    end

    it "returns Badge if no badge_term is present" do
      expect(subject.badge_term).to eq("Badge")
    end
  end

  describe "#challenge_term" do
    it "returns the set challenge_term if present" do
      subject.challenge_term = "Boss Battle"
      expect(subject.challenge_term).to eq("Boss Battle")
    end

    it "returns Challenge if no challenge_term is present" do
      expect(subject.challenge_term).to eq("Challenge")
    end
  end

  describe "#fail_term" do
    it "returns the set fail_term if present" do
      subject.fail_term = "Miss"
      expect(subject.fail_term).to eq("Miss")
    end

    it "returns Fail if no fail_term is present" do
      expect(subject.fail_term).to eq("Fail")
    end
  end

  describe "#group_term" do
    it "returns the set group_term if present" do
      subject.group_term = "Flange"
      expect(subject.group_term).to eq("Flange")
    end

    it "returns Group if no group_term is present" do
      expect(subject.group_term).to eq("Group")
    end
  end

  describe "#pass_term" do
    it "returns the set pass_term if present" do
      subject.pass_term = "Win"
      expect(subject.pass_term).to eq("Win")
    end

    it "returns Pass if no pass_term is present" do
      expect(subject.pass_term).to eq("Pass")
    end
  end

  describe "#team_term" do
    it "returns the set team_term if present" do
      subject.team_term = "Horde"
      expect(subject.team_term).to eq("Horde")
    end

    it "returns Section if no team_term is present" do
      expect(subject.team_term).to eq("Section")
    end
  end

  describe "#team_leader_term" do
    it "returns the set team_leader_term if present" do
      subject.team_leader_term = "Captain"
      expect(subject.team_leader_term).to eq("Captain")
    end

    it "returns Team Leader if no team_leader_term is present" do
      expect(subject.team_leader_term).to eq("TA")
    end
  end

  describe "#weight_term" do
    it "returns the set weight_term if present" do
      subject.weight_term = "Kapital"
      expect(subject.weight_term).to eq("Kapital")
    end

    it "returns Weight if no weight_term is present" do
      expect(subject.weight_term).to eq("Multiplier")
    end
  end

  describe "#student_term" do
    it "returns the set student_term if present" do
      subject.student_term = "User"
      expect(subject.student_term).to eq("User")
    end

    it "returns User if no student_term is present" do
      expect(subject.student_term).to eq("Student")
    end
  end

  describe "#has_teams?" do
    it "does not have teams by default" do
      expect(subject.has_teams?).to eq(false)
    end

    it "has teams if they're turned on" do
      subject.has_teams = true
      expect(subject.has_teams?).to eq(true)
    end
  end

  describe "#has_team_challenges?" do
    it "does not have team challenges by default" do
      expect(subject.has_team_challenges?).to eq(false)
    end

    it "has team challenges if they're turned on" do
      subject.has_team_challenges = true
      expect(subject.has_team_challenges?).to eq(true)
    end
  end

  describe "#teams_visible?" do
    it "has teams visible by default" do
      expect(subject.teams_visible?).to eq(true)
    end

    it "has team invisible if it's turned off" do
      subject.teams_visible = false
      expect(subject.teams_visible?).to eq(false)
    end
  end

  describe "#has_in_team_leaderboards?" do
    it "does not have in-team leaderboards turned on by default" do
      expect(subject.has_in_team_leaderboards?).to eq(false)
    end

    it "has in-team leaderboards if they're turned on" do
      subject.has_in_team_leaderboards = true
      expect(subject.has_in_team_leaderboards?).to eq(true)
    end
  end

  describe "#active?" do
    it "returns true if the course status equals true" do
      subject.status = true
      expect(subject.active?).to eq(true)
    end

    it "returns false if the course status equals false" do
      subject.status = false
      expect(subject.active?).to eq(false)
    end
  end

  describe "#has_badges?" do
    it "does not have badges turned on by default" do
      expect(subject.has_badges?).to eq(false)
    end

    it "has badges if they're turned on" do
      subject.has_badges = true
      expect(subject.has_badges?).to eq(true)
    end
  end

  describe "#valuable_badges?" do
    it "does not have badge with points by default" do
      expect(subject.valuable_badges?).to eq(false)
    end

    it "registers as having valuable has badges with points if they exist" do
      badge = create(:badge, full_points: 1000, course: subject)
      expect(subject.valuable_badges?).to eq(true)
    end
  end

  describe "#formatted_short_name" do
    it "uses the course number if that's all that's present" do
      expect(subject.formatted_short_name).to eq(subject.course_number)
    end

    it "creates a formatted short name that includes the course number, semester, and year if they're present" do
      subject.semester = "Fall"
      subject.year = "2015"

      expect(subject.formatted_short_name).to eq("#{subject.course_number} #{(subject.semester).capitalize.first[0]}#{subject.year}")
    end

  end

  describe "#time_zone" do
    subject { course.time_zone }
    let(:course) { create(:course) }

    it "defaults to Eastern Time" do
      expect(subject).to eq("Eastern Time (US & Canada)")
    end
  end

  describe "#total_points" do
    it "sums up the available points in the assignments if there's no point total set" do
      course = create(:course)
      course.full_points = nil
      assignment = create(:assignment, course_id: course.id, full_points: 101)
      assignment_2 = create(:assignment, course_id: course.id, full_points: 1000)
      expect(course.total_points).to eq(1101)
    end
  end

  describe "#student_weighted?" do
    it "returns false if no weights are set" do
      subject.has_multipliers = nil
      expect(subject.student_weighted?).to eq(false)
    end

    it "returns true if weights have been set by the instructor" do
      subject.has_multipliers = true
      expect(subject.student_weighted?).to eq(true)
    end
  end

  describe "#assignment_weight_open?" do
    it "returns false if the weights_close_at date is past" do
      subject.weights_close_at = Date.today - 1
      expect(subject.assignment_weight_open?).to eq(false)
    end

    it "returns true if there is no close at date" do
      expect(subject.assignment_weight_open?).to eq(true)
    end

    it "returns true if the close date is in the future" do
      subject.weights_close_at = Date.today + 1
      expect(subject.assignment_weight_open?).to eq(true)
    end
  end

  describe "#has_team_roles?" do
    it "turns team roles for students in their profile settings to true if the instructor turns them on" do
      subject.has_team_roles = true
      expect(subject.has_team_roles?).to eq(true)
    end
    it "returns false for team roles if the instructor has not turned them on" do
      subject.has_team_roles = false
      expect(subject.has_team_roles?).to eq(false)
    end
  end

  describe "#accepts_submissions?" do
    it "returns true if the instructor has turned submissions on" do
      subject.accepts_submissions = true
      expect(subject.accepts_submissions?).to eq(true)
    end
    it "returns false for submissions if the instructor has not turned them on" do
      subject.accepts_submissions = false
      expect(subject.accepts_submissions?).to eq(false)
    end
  end

  describe "#assignment_weight_for_student(student)" do
    it "sums the assignment weights the student has spent" do
      student = create(:user, courses: [subject], role: :student)
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      assignment_weight_2 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_for_student(student)).to eq(4)
    end
  end

  describe "#assignment_weight_spent_for_student(student)" do
    it "returns false if the student has not yet spent enough weights" do
      subject.total_weights = 4
      student = create(:user, courses: [subject], role: :student)
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_spent_for_student(student)).to eq(false)
    end

    it "returns true if the student has spent enough weights" do
      subject.total_weights = 4
      student = create(:user, courses: [subject], role: :student)
      assignment_weight_1 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      assignment_weight_2 = create(:assignment_type_weight, student: student, course: subject, weight: 2)
      expect(subject.assignment_weight_spent_for_student(student)).to eq(true)
    end
  end

  describe "#point_total_for_challenges" do
    it "sums up the total number of points in the challenges" do
      challenge = create(:challenge, course: subject, full_points: 101)
      challenge_2 = create(:challenge, course: subject, full_points: 1000)
      expect(subject.point_total_for_challenges).to eq(1101)
    end
  end

  describe "#recalculate_student_scores" do
    it "recalculates scores for each student id" do
      allow(subject).to receive(:ordered_student_ids).and_return [1, 2]
      expect{ subject.recalculate_student_scores }.to change { queue(ScoreRecalculatorJob).size }.by(2)
    end
  end

  describe "#ordered_student_ids" do
    it "returns an ordered array of student ids" do
      student_2 = create(:user, courses: [subject], role: :student)
      student_1 = create(:user, courses: [subject], role: :student)
      student_3 = create(:user, courses: [subject], role: :student)
      expect(subject.ordered_student_ids).to eq([student_2.id, student_1.id, student_3.id])
    end
  end

  describe "#create_admin_memberships" do
    it "creates admin memberships for all courses automatically on creation of new courses" do
      admin = create(:user, admin: true)
      course = create(:course)
      new_course = create(:course)
      expect(admin.course_memberships.count).to eq(2)
    end
  end

  describe "#nonpredictors" do
    it "returns the students who have not yet predicted any assignments" do
      course = create(:course)
      student = create(:user, courses: [course], role: :student)
      student_2 = create(:user, courses: [course], role: :student)
      assignment = create(:assignment, course: course)
      peg = create(:predicted_earned_grade, student: student, assignment: assignment)
      expect(course.nonpredictors).to eq([student_2])
    end
  end
end
