describe Team do
  let(:course) { create(:course) }

  describe "validations" do

    it "requires that the team name be unique per course" do
      create :team, course_id: course.id, name: "Zeppelin"
      team = Team.new course_id: course.id, name: "zeppelin"
      expect(team).to_not be_valid
      expect(team.errors[:name]).to include "has already been taken"
    end

    it "can have the same name if it's for a different course" do
      create :team, course_id: course.id, name: "Zeppelin"
      team = Team.new course_id: create(:course).id, name: "Zeppelin"
      expect(team).to be_valid
    end
  end

  describe "#copy" do
    let(:team) { create :team, course: course }

    # copying the course, because a team should not be copied within a course
    subject { course.copy("with_students").teams.first }

    it "makes a duplicated copy of itself" do
      expect(subject).to_not eq team
    end

    describe "with members" do
      let!(:team_membership) { create :team_membership, team: team }


      it "copies the team memberships" do
        expect(subject.team_memberships.size).to eq 1
        expect(subject.team_memberships.map(&:team_id)).to eq [subject.id]
      end
    end

    it "overrides the specified attributes" do
      attributes = { rank: 9 }
      subject = team.copy attributes
      expect(subject.rank).to eq attributes[:rank]
    end

    it "resets the values for the scores" do
      team.update(challenge_grade_score: 100, average_score: 100)
      expect(subject.challenge_grade_score).to be_zero
      expect(subject.average_score).to be_zero
    end
  end

  describe ".find_by_course_and_name" do
    let(:team) { create :team }

    it "returns the team for the specific course id and name" do
      result = Team.find_by_course_and_name team.course_id, team.name.upcase
      expect(result).to eq team
    end
  end

  describe "#badge_count" do
    it "returns the number of earned badges for the team" do
      course = create(:course)
      team = create(:team, course: course)
      student = create(:user)
      student_2 = create(:user)
      badge = create(:badge)
      team.students << [student, student_2]
      earned_badge = create(:earned_badge, student: student, course: course, student_visible: true)
      earned_badge_1 = create(:earned_badge, student: student, course: course, student_visible: true)
      earned_badge_2 = create(:earned_badge, student: student_2, course: course, student_visible: true)
      earned_badge_3 = create(:earned_badge, student: student_2, course: course, student_visible: true)
      expect(team.badge_count).to eq(4)
    end
  end

  describe "#total_earned_points" do
    let(:course) { create :course }
    let(:team) { create :team, course: course }
    let(:course_memberships) { create_list :course_membership, 3, :student, course: course, score: 100 }

    it "returns the total points earned by active students for the team" do
      course_memberships.last.update(active: false)
      team.students << [course_memberships.map(&:user)]
      expect(team.total_earned_points).to eq 200
    end
  end

  describe "#average_score" do
    it "returns 0 if there's no one on the team" do
      team = create(:team)
      expect(team.average_score).to eq(0)
    end

    it "returns the average score if team members are present" do
      course = create(:course)
      team = create(:team, course: course)
      student = create(:user)
      course_membership = create(:course_membership, :student, user: student, course: course, score: 100)
      student_2 = create(:user)
      course_membership = create(:course_membership, :student, user: student_2, course: course, score: 100)
      team.students << [student, student_2]
      team.update_average_score!
      expect(team.reload.average_score).to eq(100)
    end
  end

  describe "challenge_grade_score" do
    it "sums all earned challenge grades together" do
      team = create(:team)
      challenge_grade = create(:student_visible_challenge_grade, raw_points: 100, team: team)
      challenge_grade_2 = create(:student_visible_challenge_grade, raw_points: 100, team: team)
      challenge_grade_3 = create(:student_visible_challenge_grade, raw_points: 100, team: team)
      team.update_challenge_grade_score!
      expect(team.challenge_grade_score).to eq(300)
    end

    it "should not include grades that are not student visible" do
      team = create(:team)
      challenge_grade = create(:student_visible_challenge_grade, raw_points: 100, team: team)
      challenge_grade_2 = create(:challenge_grade, raw_points: 100, team: team, status: nil)
      expect(team.challenge_grade_score).to eq(100)
    end
  end

  describe "#update_team_rank" do

    it "Reassigns rank based on scores" do
      course = create(:course, team_score_average: false)
      team_1 = create(:team, course: course)
      team_2 = create(:team, course: course)

      challenge = create(:challenge, course: course)
      challenge_grade = create(:student_visible_challenge_grade, challenge: challenge, team: team_1, raw_points: 100)
      challenge_grade_2 = create(:student_visible_challenge_grade, challenge: challenge, team: team_2, raw_points: 10000)

      team_2.update_ranks!
      team_2.reload
      expect(team_2.rank).to eq(1)
    end

  end

  describe "setting the two team scores" do
    let(:course) { create :course }
    let(:team) { create(:team, course: course) }

    it "returns the average points for the team" do
      team.average_score = nil
      student = create(:user)
      course_membership = create(:course_membership, :student, user: student, course: course, score: 100)
      student_2 = create(:user)
      course_membership = create(:course_membership, :student, user: student_2, course: course, score: 300)
      team.students << [student, student_2]
      team.update_average_score!
      expect( team.instance_eval { average_score } ).to eq(200)
    end

    it "sets the challenge grade score for the team" do
      team.challenge_grade_score = nil
      challenge_grade = create(:student_visible_challenge_grade, raw_points: 100, team: team)
      challenge_grade_2 = create(:student_visible_challenge_grade, raw_points: 2000, team: team)
      team.update_challenge_grade_score!
      expect( team.instance_eval { challenge_grade_score } ).to eq(2100)
    end
  end
end
