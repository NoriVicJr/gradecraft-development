require "active_record_spec_helper"

describe User do
  let!(:world) do
    World.create.with(:course, :student, :assignment, :grade)
  end
  let(:course) { world.course }
  let(:student) { world.student }
  let(:assignment) { world.assignment }
  let(:grade) { world.grade }

  describe "validations" do
    it "requires the password confirmation to match" do
      user = User.new password: "test", password_confirmation: "blah"
      expect(user).to_not be_valid
      expect(user.errors[:password_confirmation]).to include "doesn't match Password"
    end

    it "requires that there is a password confirmation" do
      student.password = "test"
      expect(student).to_not be_valid
      expect(student.errors[:password_confirmation]).to include "can't be blank"
    end
  end

  describe "ordering" do
    it "should return users alphabetical by last name" do
      User.destroy_all
      student = create(:user, last_name: "Zed")
      student2 = create(:user, last_name: "Alpha")
      expect(User.all).to eq([student2,student])
    end
  end

  describe ".find_by_insensitive_email" do
    it "should return the user no matter what the case the email address is in" do
      expect(User.find_by_insensitive_email(student.email.upcase)).to eq student
    end
  end

  describe ".find_by_insensitive_username" do
    it "should return the user no matter what the case the username is in" do
      expect(User.find_by_insensitive_username(student.username.upcase)).to eq student
    end
  end

  describe ".email_exists?" do
    it "should return true if the email already exists" do
      expect(User.email_exists?(student.email.upcase)).to eq true
    end

    it "should return false if the email does not exist" do
      expect(User.email_exists?("blah@somewhere-cool.biz")).to eq false
    end
  end

  describe "student directory names" do
    let(:user) { create(:user, first_name: "Ben", last_name: "Bailey", username: "bbailey10") }

    describe "#student_directory_name" do
      it "formats the student info into an alphabetical student directory name" do
        expect(user.student_directory_name).to eq("Bailey, Ben")
      end
    end

    describe "#student_directory_name_with_username" do
      it "formats the student directory name with username" do
        expect(user.student_directory_name_with_username).to eq("Bailey, Ben - Bbailey10")
      end
    end
  end

  describe "formatted name keys" do
    let(:user) { create(:user, first_name: "Ben", last_name: "Bailey", username: "bbailey10") }

    describe "#full_name" do
      it "prints the full name" do
        expect(user.full_name).to eq("Ben Bailey")
      end
    end
  end

  describe "#time_zone" do
    subject { user.time_zone }
    let(:user) { create(:user) }

    it "defaults to Eastern Time" do
      expect(subject).to eq("Eastern Time (US & Canada)")
    end
  end

  describe "#same_name_as?" do
    let(:ben_bailey1) { create(:user, first_name: "Ben", last_name: "Bailey") }
    let(:ben_bailey2) { create(:user, first_name: "Ben", last_name: "Bailey") }
    let(:roger_daltry) { create(:user, first_name: "Roger", last_name: "Daltry") }

    context "has the same name as the user given" do
      it "returns true" do
        expect(ben_bailey1.same_name_as?(ben_bailey2)).to be_truthy
      end
    end

    context "has a different name than the user given" do
      it "returns false" do
        expect(ben_bailey1.same_name_as?(roger_daltry)).to be_falsey
      end
    end
  end

  describe ".students_being_graded" do
    let(:student_not_being_graded) { create(:user) }
    before do
      create(:course_membership, course: course, user: student_not_being_graded, auditing: true)
    end

    it "returns all the students that are being graded" do
      result = User.students_being_graded(course)
      expect(result.pluck(:id)).to eq [student.id]
    end

    context "with a team" do
      let(:student_in_team) { create :user }
      let(:team) { create :team, course: course }
      before do
        create(:course_membership, course: course, user: student_in_team)
        team.students << student_in_team
      end

      it "returns only students in the team that are being graded" do
        result = User.students_being_graded(course, team)
        expect(result.pluck(:id)).to eq [student_in_team.id]
      end
    end
  end

  describe ".students_by_team" do
    let(:team) { world.create_team.team }

    it "returns only students in the team" do
      team.students << student
      result = User.students_by_team(course, team)
      expect(result.pluck(:id)).to eq [student.id]
    end
  end

  describe "#activated?" do
    it "is activated when the activation state is active" do
      user = build :user, activation_state: "active"
      expect(user).to be_activated
    end

    it "is not activated when the activation state is pending" do
      user = build :user, activation_state: "pending"
      expect(user).to_not be_activated
    end
  end

  describe "#name" do
    let(:student) {create :user, first_name: "Daniel", last_name: "Hall"}

    it "returns the student's full name if present" do
      expect(student.name).to eq("Daniel Hall")
    end

    it "returns the User ID if not" do
      student.last_name = nil
      student.first_name = nil
      expect(student.name).to eq("User #{student.id}")
    end
  end

  describe "#auditing_course?(course)" do
    let(:student) { create :user }

    it "returns true if the student is auditing" do
      create(:course_membership, course: course, user: student, auditing: true)
      expect(student.auditing_course?(course)).to eq(true)
    end

    it "returns false if the student is being graded" do
      membership = create(:course_membership, course: course, user: student, auditing: false)
      expect(student.auditing_course?(course)).to eq(false)
    end
  end

  describe "#self_reported_done?" do
    it "is not self reported if there are no grades" do
      expect(student).to_not be_self_reported_done(world.assignment)
    end

    it "is self reported if there is at least one graded grade" do
      world.grade.update_attribute :status, "Graded"
      expect(student).to be_self_reported_done(world.assignment)
    end
  end

  describe "#role" do
    it "returns the first role found from the course membership" do
      expect(student.role(course)).to eq "student"
    end

    it "returns nil if the course membership is not found" do
      expect(student.role(Course.new)).to eq nil
    end

    it "returns admin if the user is an admin" do
      student.admin = true
      student.save
      expect(student.role(course)).to eq "admin"
    end
  end

  describe "#public_name" do
    let(:student) {create :user, first_name: "Daniel", last_name: "Hall", display_name: "Hector's Kid"}
    it "returns the username's display name if it's present" do
      expect(student.public_name).to eq("Hector's Kid")
    end

    it "returns the user's name otherwise" do
      student.display_name = nil
      expect(student.public_name).to eq("Daniel Hall")
    end
  end

  describe "#is_staff?(course)" do
    let(:user) { create :user }
    it "returns true if the user is a professor in the course" do
      membership = create(:course_membership, course: course, user: user, role: "professor")
      expect(user.is_staff?(course)).to eq(true)
    end
    it "returns true if the user is a GSI in the course" do
      membership = create(:course_membership, course: course, user: user, role: "gsi")
      expect(user.is_staff?(course)).to eq(true)
    end
    it "returns true if the user is an admin in the course" do
      membership = create(:course_membership, course: course, user: user, role: "admin")
      expect(user.is_staff?(course)).to eq(true)
    end

    it "returns false if the user is a student in the course" do
      membership = create(:course_membership, course: course, user: user, role: "student")
      expect(user.is_staff?(course)).to eq(false)
    end

    it "requires an email to end with umich if an internal user" do
      student.internal = true
      student.email = "blah@example.com"
      expect(student).to_not be_valid
      expect(student.errors[:email]).to include "must be a University of Michigan email"
    end

    it "requires an email to end with umich if it was saved with a umich email" do
      student.email = "blah@umich.edu"
      student.save
      student.email = "blah@example.com"
      expect(student).to_not be_valid
      expect(student.errors[:email]).to include "must be a University of Michigan email"
    end
  end

  describe "#team_for_course(course)" do
    let(:student) { create :user }
    let(:team) { create :team, course: course }

    before do
      create(:course_membership, course: course, user: student)
    end

    it "returns the student's team for the course" do
      create(:team_membership, team: team, student: student)
      expect(student.team_for_course(course)).to eq(team)
    end

    it "returns nil if the student doesn't have a team" do
      expect(student.team_for_course(course)).to eq(nil)
    end
  end

  describe "#team_leaders(course)" do
    let(:student) { create :user }
    let(:team_leader) { create :user }
    let(:team) { create :team, course: course }

    before do
      create(:course_membership, course: course, user: student)
    end

    it "returns the students team leaders if they're present" do
      create(:team_leadership, team: team, leader: team_leader)
      create(:team_membership, team: team, student: student)
      expect(student.team_leaders(course)).to eq([team_leader])

    end

    it "returns nil if there are no team leaders present" do
      create(:team_membership, team: team, student: student)
      expect(student.team_leaders(course)).to eq([])
    end
  end

  describe "#team_leaderships_for_course(course)" do
    let(:team_leader) { create :user }
    let(:team) { create :team, course: course }

    it "returns the team leaderships if they're present" do
      leadership = create(:team_leadership, team: team, leader: team_leader)
      expect(team_leader.team_leaderships(course)).to eq([leadership])
    end

    it "returns nil if there are no team leaderships present" do
      expect(team_leader.team_leaderships(course)).to eq([])
    end
  end

  describe "#character_profile(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, course: course, user: student, character_profile: "The six-fingered man.")
    end

    it "returns the student's character profile if it's present" do
      expect(student.character_profile(course)).to eq("The six-fingered man.")
    end
  end

  describe "#archived_courses" do
    let(:student) { create :user }

    before do
      create(:course_membership, course: course, user: student)
    end

    it "returns all archived courses for a student" do
      course_2 = create(:course, status: false)
      create(:course_membership, course: course_2, user: student)
      expect(student.archived_courses).to eq([course_2])
    end
  end

  describe "#cached_score_for_course(course)" do
    let(:student) { create :user }

    it "returns the student's score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      expect(student.cached_score_for_course(course)).to eq(100000)
    end

    it "returns 0 if the student has no score" do
      create(:course_membership, course: course, user: student)
      expect(student.cached_score_for_course(course)).to eq(0)
    end
  end

  describe "#scores_for_course(course)" do
    skip "implement"
  end

  describe "#grade_for_course(course)" do
    let(:student) { create :user }

    it "returns the grade scheme element that matches the students score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      gse = create(:grade_scheme_element, course: course, low_range: 80000, high_range: 120000)
      expect(student.grade_for_course(course)).to eq(gse)
    end
  end

  describe "#grade_level_for_course(course)" do
    let(:student) { create :user }

    it "returns the grade scheme level name that matches the student's score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      gse = create(:grade_scheme_element, course: course, low_range: 80000, high_range: 120000, level: "Meh")
      expect(student.grade_level_for_course(course)).to eq("Meh")
    end
  end

  describe "#grade_letter_for_course(course)" do
    let(:student) { create :user }

    it "returns the grade scheme letter name that matches the student's score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      gse = create(:grade_scheme_element, course: course, low_range: 80000, high_range: 120000, letter: "Q")
      expect(student.grade_letter_for_course(course)).to eq("Q")
    end
  end

  describe "#next_element_level(course)" do
    let(:student) { create :user }

    it "returns the next level above a student's current score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      gse = create(:grade_scheme_element, course: course, low_range: 80000, high_range: 120000, letter: "Q")
      gse_1 = create(:grade_scheme_element, course: course, low_range: 120001, high_range: 150000, letter: "R")
      gse_2 = create(:grade_scheme_element, course: course, low_range: 150001, high_range: 180000, letter: "S")
      expect(student.next_element_level(course)).to eq(gse_1)
    end
  end

  describe "#points_to_next_level(course)" do
    let(:student) { create :user }

    it "returns the next level above a student's current score for the course" do
      create(:course_membership, course: course, user: student, score: 100000)
      gse = create(:grade_scheme_element, course: course, low_range: 80000, high_range: 120000, letter: "Q")
      gse_1 = create(:grade_scheme_element, course: course, low_range: 120001, high_range: 150000, letter: "R")
      expect(student.points_to_next_level(course)).to eq(20001)
    end
  end

  describe "#grade_released_for_assignment?(assignment)" do
    let(:student) { create :user }
    let(:assignment) { create :assignment}
    let(:grade) {create :grade, assignment: assignment, student: student}

    it "returns false if the grade is not student visible" do
      expect(student.grade_released_for_assignment?(assignment)).to eq(false)
    end

    it "returns true if the grade is graded and does not require release" do
      grade.status = "Graded"
      grade.save!
      expect(student.grade_released_for_assignment?(assignment)).to eq(true)
    end

    it "returns false if the grade is graded and release is required" do
      assignment.release_necessary = true
      assignment.save
      grade.status = "Graded"
      grade.save!
      expect(student.grade_released_for_assignment?(assignment)).to eq(false)
    end

    it "returns true if the grade is released and release is required" do
      assignment.release_necessary = true
      assignment.save
      grade.status = "Released"
      grade.save!
      expect(student.grade_released_for_assignment?(assignment)).to eq(true)
    end
  end

  describe "#grade_for_assignment(assignment)" do
    let(:student) { create :user }
    let(:assignment) { create :assignment}

    it "returns the grade for an assignment if it exists" do
      grade = create(:grade, assignment: assignment, student: student)
      expect(student.grade_for_assignment(assignment)).to eq(grade)
    end
  end

  describe "#grade_for_assignment_id(assignment_id)" do
    let(:student) { create :user }
    let(:assignment) { create :assignment}

    it "returns the grade for an assignment of a particular id if it exists" do
      grade = create(:grade, assignment: assignment, student: student)
      expect(student.grade_for_assignment_id(assignment.id)).to eq([grade])
    end
  end

  describe "#submission_for_assignment(assignment)" do
    let(:student) { create :user }
    let(:assignment) { create :assignment}

    it "returns the submission for an assignment if it exists" do
      submission = create(:submission, assignment: assignment, student: student)
      expect(student.submission_for_assignment(assignment)).to eq(submission)
    end
  end

  describe "#earned_badge_score_for_course(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
      create(:earned_badge, score: 100, student: student, course: course, student_visible: true)
      create(:earned_badge, score: 300, student: student, course: course, student_visible: true)
    end

    it "returns the sum of the badge score for a student" do
      expect(student.earned_badge_score_for_course(course)).to eq(400)
    end

    it "does not include earned badges that have not yet been made student visible" do
      create(:earned_badge, score: 155, student: student, course: course, student_visible: false)
      expect(student.earned_badge_score_for_course(course)).to eq(400)
    end
  end

  describe "#earned_badges_for_course(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "returns the students' earned_badges for a course" do
      earned_badge_1 = create(:earned_badge, score: 100, student: student, course: course, student_visible: true)
      earned_badge_2 = create(:earned_badge, score: 300, student: student, course: course, student_visible: true)
      expect(student.earned_badges_for_course(course)).to eq([earned_badge_1, earned_badge_2])
    end
  end

  describe "#earned_badge_for_badge(badge)" do
    let(:student) { create :user }
    let(:badge) { create :badge, course: course }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "returns the students' earned_badges for a particular badge" do
      earned_badge_1 = create(:earned_badge, badge: badge, student: student, course: course, student_visible: true)
      expect(student.earned_badge_for_badge(badge)).to eq([earned_badge_1])
    end
  end

  describe "#earned_badges_for_badge_count(badge)" do
    let(:student) { create :user }
    let(:badge) { create :badge, course: course }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "returns the students' earned_badges for a course" do
      earned_badge_1 = create(:earned_badge, badge: badge, student: student, course: course, student_visible: true)
      earned_badge_2 = create(:earned_badge, badge: badge, student: student, course: course, student_visible: true)
      expect(student.earned_badges_for_badge_count(badge)).to eq(2)
    end
  end

  describe "#earnable_course_badges_sql_conditions(grade)" do
    skip "implement"
    #   Badge
    #     .unscoped
    #     .where("(id not in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ?))", self[:id], grade[:course_id])
    #     .where("(id in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ?) and can_earn_multiple_times = ?)", self[:id], grade[:course_id], true)
    #     .where("(id in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ? and earned_badges.grade_id = ?) and can_earn_multiple_times = ?)", self[:id], grade[:course_id], grade[:id], false)
  end

  describe "#earn_badges_for_grade(badges, grade)" do
    skip "implement"
    #   raise TypeError, "First argument must be a Badge object" unless badge.class == Badge
    #   badges.collect do |badge|
    #     earned_badges.create badge: badge, course: badge.course, grade: grade
    #   end
  end

  describe "#weight_for_assignment_type(assignment_type)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "should return a student's assigned weight for an assignment type" do
      assignment_type = create(:assignment_type, course: course)
      assignment = create(:assignment, assignment_type: assignment_type, course: course)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 3)
      expect(student.weight_for_assignment_type(assignment_type)).to eq(3)
    end
  end

  describe "#weight_spent?(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "should return the summed weight count for a course, for a student" do
      course.total_assignment_weight = 6
      course.max_assignment_weight = 4
      course.max_assignment_types_weighted = 3
      assignment_type = create(:assignment_type, course: course, student_weightable: true)
      assignment_type_2 = create(:assignment_type, course: course, student_weightable: true)
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type_2)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type, weight: 4)
      create(:assignment_type_weight, student: student, course: course, assignment_type: assignment_type_2, weight: 2)
      expect(student.weight_spent?(course)).to eq(true)
    end
  end

  describe "#total_weight_spent(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "should return the summed weight count for a course, for a student" do
      course.total_assignment_weight = 6
      course.max_assignment_weight = 4
      course.max_assignment_types_weighted = 3
      assignment_type = create(:assignment_type, course: course, student_weightable: true)
      assignment_type_2 = create(:assignment_type, course: course, student_weightable: true)
      assignment_type_3 = create(:assignment_type, course: course, student_weightable: true)
      assignment = create(:assignment, course: course, assignment_type: assignment_type)
      assignment_2 = create(:assignment, course: course, assignment_type: assignment_type_2)
      assignment_3 = create(:assignment, course: course, assignment_type: assignment_type_3)
      assignment_weight_1 = create(:assignment_type_weight, student: student, assignment_type: assignment_type, weight: 2)
      assignment_weight_2 = create(:assignment_type_weight, student: student, assignment_type: assignment_type_2, weight: 2)
      assignment_weight_3 = create(:assignment_type_weight, student: student, assignment_type: assignment_type_3, weight: 2)
      expect(student.total_weight_spent(course)).to eq(6)
    end
  end

  describe "#weighted_assignments?" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
    end

    it "should return true if the student has weighted assignments" do
      create(:assignment_type_weight, student: student, course: course)
      expect(student.weighted_assignments?(course)).to eq(true)
    end

    it "should return false if the student has not weighted any assignments" do
      expect(student.weighted_assignments?(course)).to eq(false)
    end
  end

  describe "#weight_count(course)" do
    let(:student) { create :user }

    before do
      create(:course_membership, user: student, course: course)
      create(:assignment_type_weight, student: student, course: course)
      create(:assignment_type_weight, student: student, course: course)
      create(:assignment_type_weight, student: student, course: course)
    end

    it "should return the summed weight count for a course, for a student" do
      expect(student.weight_count(course)).to eq(3)
    end
  end

  describe "#group_for_assignment(assignment)" do
    let!(:create_group) { world.create_group }
    let(:group) { world.group }

    it "returns a student's group for a particular assignment if present" do
      FactoryGirl.create(:assignment_group, group: group, assignment: assignment)
      FactoryGirl.create(:group_membership, student: student, group: group)
      expect(student.group_for_assignment(assignment)).to eq(world.group)
    end
  end

  describe "#has_group_for_assignment?" do
    let!(:create_group) { world.create_group }
    let(:group) { world.group }

    it "returns false for individual assignments" do
      FactoryGirl.create(:assignment_group, group: group, assignment: assignment)
      FactoryGirl.create(:group_membership, student: student, group: group)
      assignment.update(grade_scope: "Individual")
      expect(student.has_group_for_assignment?(assignment)).to be_falsey
    end

    it "returns false if the student has no group membership" do
      assignment.update(grade_scope: "Group")
      expect(student.has_group_for_assignment?(assignment)).to be_falsey
    end

    it "returns true if the student is in a group" do
      assignment.update(grade_scope: "Group")
      FactoryGirl.create(:assignment_group, group: group, assignment: assignment)
      FactoryGirl.create(:group_membership, student: student, group: group)
      expect(student.has_group_for_assignment?(assignment)).to be_truthy
    end
  end

  context "earn_badges" do
    it "should be able to earn badges" do
      badges = create_list(:badge, 2, course: course)
      student.earn_badges(badges)
      badges_earned = student.earned_badges.collect {|e| e.badge }.sort_by(&:id)
      expect(badges_earned).to eq(badges.sort_by(&:id))
    end
  end

  context "student_visible_earned_badges" do
    it "should know which badges a student has earned" do
      earned_badges = create_list(:earned_badge, 3, course: course, student: student, student_visible: true)
      expect(student.student_visible_earned_badges(course)).to eq(earned_badges)
    end

    it "should not select non-visible student badges" do
      earned_badges = create_list(:earned_badge, 3, course: course, student: student, student_visible: false)
      expect(student.student_visible_earned_badges(course)).to be_empty
    end

    it "should not return unearned badges as earned badges" do
      unearned_badges = create_list(:badge, 2, course: course)
      visible_earned_badges = create_list(:earned_badge, 3, course: course, student: student)
      unique_earned_badges = student.student_visible_earned_badges(course)
      expect(unique_earned_badges).not_to include(*unearned_badges)
    end
  end

  context "unique_student_earned_badges" do
    before(:each) do
      create_list(:earned_badge, 3, course: course, student: student, student_visible: true)
    end

    # Intermittent failure?
    it "should know which badges are unique to those student earned badges" do
      sorted_badges = student.earned_badges.collect(&:badge).sort_by(&:id).flatten
      expect(student.unique_student_earned_badges(course)).to eq(sorted_badges)
    end

    it "should not return badges associated with student-unearned badges" do
      badges_unearned = create_list(:badge, 2, course: course)
      expect(student.unique_student_earned_badges(course)).not_to include(*badges_unearned)
    end
  end

  context "student_visible_unearned_badges" do
    it "should know which badges a student has yet to earn" do
      badges = create_list(:badge, 2, course: course, visible: true)
      expect(student.student_visible_unearned_badges(course)).to eq(badges)
    end

    it "should not return earned badges as unearned ones" do
      earned_badges = create_list(:earned_badge, 2, course: course, student: student)
      expect(student.student_visible_unearned_badges(course)).not_to include(*earned_badges)
    end
  end

  context "instructor is editing the grade for a student's submission" do
    before(:each) do
      @single_badge = world.create_badge(can_earn_multiple_times: false).badge
      @multi_badge = world.create_badge(can_earn_multiple_times: true).badges.last

      another_assignment = world.create_assignment.assignments.last
      @another_grade = world.create_grade(assignment: another_assignment).grades.last
    end

    it "should not see badges that aren't included in the current course" do
      bizarro = World.create.with(:course, :student, :assignment, :grade, :badge)
      expect(student.earnable_course_badges_for_grade(world.grade)).not_to include(bizarro.badge)
    end

    it "should see badges for the current course" do
      EarnedBadge.destroy_all course_id: course[:id]
      expect(student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge, @multi_badge)
    end

    it "should show course badges that the student has yet to earn", broken: true do
      EarnedBadge.destroy_all course_id: course[:id]
      expect(student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge, @multi_badge)
    end

    it "should not show badges that the student has earned for other grades, and can't be earned multiple times" do
      student.earn_badge_for_grade(@single_badge, @another_grade) # earn the badge on another grade
      expect(student.earnable_course_badges_for_grade(world.grade)).not_to include(@single_badge)
    end

    it "should show badges that the student has earned but CAN be earned multiple times", broken: true do
      student.earn_badge_for_grade(@multi_badge, world.grade)
      expect(student.earnable_course_badges_for_grade(world.grade)).to include(@multi_badge)
    end

    it "should show badges that the student has earned for the current grade, even if it can't be earned multiple times" do
      student.earn_badge_for_grade(@single_badge, world.grade)
      expect(student.earnable_course_badges_for_grade(world.grade)).to include(@single_badge)
    end
  end

  context "user earns just one badge" do
    let!(:create_badge) { world.create_badge }
    let(:current_badge) { world.badge }

    it "should create a valid earned badge" do
      expect(student.earn_badge(current_badge).class).to eq(EarnedBadge)
      expect(student.earn_badge(current_badge).valid?).to be true
    end

    it "should not error out when earning one badge" do
      expect { student.earn_badge(current_badge) }.to_not raise_error
    end

    it "should choke on an array of badges" do
      expect { student.earn_badge([current_badge])}.to raise_error(TypeError)
    end
  end

  context "student_invisible_badges" do
    it "should return invisible badges for which the student has earned a badge" do
      invisible_badges = create_list(:badge, 2, course: course, visible: false)
      student.earn_badges(invisible_badges)
      badges_earned_by_id = student.student_invisible_badges(course)
      expect(badges_earned_by_id).to eq(invisible_badges)
    end

    it "should not return visible badges for which the student has earned a badge" do
      visible_badges = create_list(:badge, 2, course: course, visible: true)
      student.earn_badges(visible_badges)
      badges_earned_by_id = student.student_invisible_badges(course).sort_by(&:id)
      expect(badges_earned_by_id).not_to eq(visible_badges.sort_by(&:id))
    end
  end
end
