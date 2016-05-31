require "active_record_spec_helper"

describe ChallengeGrade do
  subject { build(:challenge_grade) }

  context "validations" do
    it "is valid with a team, and a challenge" do
      expect(subject).to be_valid
    end

    it "is invalid without a team" do
      subject.team = nil
      expect(subject).to be_invalid
    end

    it "is invalid without a challenge" do
      subject.challenge = nil
      expect(subject).to be_invalid
    end
  end

  describe ".releasable_through" do
    it "returns challenge" do
      expect(described_class.releasable_relationship).to eq :challenge
    end
  end

  describe "#score" do
    it "returns the challenge grade score if present" do
      challenge_grade = create(:challenge_grade, score: 100)
      expect(challenge_grade.score).to eq(100)
    end

    it "returns nil if there's no score present" do
      challenge_grade = create(:challenge_grade, score: nil)
      expect(challenge_grade.score).to eq(nil)
    end
  end

  describe ".student_visible" do
    it "returns all grades that were released or were graded but no release was necessary" do
      graded_grade = create :challenge_grade, status: "Graded"
      released_grade = create :challenge_grade, status: "Released"
      create :grades_not_released_challenge_grade

      expect(described_class.student_visible).to eq [graded_grade, released_grade]
    end
  end

  describe "#cache_team_score" do
    it "saves the team scores" do
      team = create(:team, challenge_grade_score: 0, average_score: 0)
      challenge_grade = create(:challenge_grade, team: team, score: 100, status: "Released")
      challenge_grade.cache_team_scores
      expect(team.challenge_grade_score).to eq(100)
    end
  end

  describe "#is_graded?" do
    it "returns true if the challenge grade is graded" do
      challenge_grade = create(:challenge_grade, status: "Graded")
      expect(challenge_grade.is_graded?).to eq(true)
    end
    it "returns false if the challenge grade is not graded" do
      challenge_grade = create(:challenge_grade, status: nil)
      expect(challenge_grade.is_graded?).to eq(false)
    end
  end

  describe "#is_released?" do
    it "returns true if the challenge grade is released" do
      challenge_grade = create(:challenge_grade, status: "Released")
      expect(challenge_grade.is_released?).to eq(true)
    end

    it "returns false if the challenge grade is not graded" do
      challenge_grade = create(:challenge_grade, status: nil)
      expect(challenge_grade.is_released?).to eq(false)
    end

    it "returns false if the challenge grade is graded but not released" do
      challenge_grade = create(:challenge_grade, status: "Graded")
      expect(challenge_grade.is_released?).to eq(false)
    end
  end
end
