class Team < ActiveRecord::Base
  attr_accessible :name, :course, :course_id, :student_ids, :score, :students,
    :leaders, :teams_leaderboard, :in_team_leaderboard, :banner, :rank,
    :leader_ids

  validates_presence_of :course, :name
  validates :name, uniqueness: { case_sensitive: false, scope: :course_id }

  # Teams belong to a single course
  belongs_to :course, touch: true

  has_many :team_memberships
  has_many :students, through: :team_memberships, autosave: true
  has_many :team_leaderships
  has_many :leaders, through: :team_leaderships

  # Teams design banners that they display on the leadboard
  mount_uploader :banner, ImageUploader

  # Teams don't currently earn badges directly - but they are recognized for
  # the badges their students earn
  has_many :earned_badges, through: :students

  # Teams compete through challenges, which earn points through challenge_grades
  has_many :challenge_grades
  has_many :challenges, through: :challenge_grades

  accepts_nested_attributes_for :team_memberships

  # Various ways to sort the display of teams
  scope :order_by_high_score, -> { order "teams.challenge_grade_score DESC" }
  scope :order_by_low_score, -> { order "teams.challenge_grade_score ASC" }
  scope :order_by_average_high_score, -> { order "average_points DESC"}
  scope :alpha, -> { order "teams.name ASC"}

  def self.find_by_course_and_name(course_id, name)
    where(course_id: course_id)
      .where("LOWER(name) = :name", name: name.downcase).first
  end

  # How many students are on the team
  def member_count
    students.count
  end

  # How many badges the students on the team have earned total
  def badge_count
    earned_badges.where(course_id: self.course_id).student_visible.count
  end

  # The number of points all students have earned total
  def total_earned_points
    total_score = 0
    students.each do |student|
      total_score += (student.cached_score_for_course(course) || 0 )
    end
    return total_score
  end

  # The average points amongst all students on the team
  def average_points
    if member_count > 0
      average_points = total_earned_points / member_count
    else
      return 0
    end
  end

  def update_ranks!
    @teams = self.course.teams
    if self.course.team_score_average?
      rank_index = @teams.pluck(:average_score).uniq.sort.reverse
    elsif self.course.challenges.present?
      rank_index = @teams.pluck(:challenge_grade_score).uniq.sort.reverse
    end

    @teams.each do |team|
      if self.course.team_score_average?
        rank = rank_index.index(team.average_score) + 1
      elsif self.course.challenges.present?
        rank = (rank_index.index(team.challenge_grade_score) || 0) + 1
      end
      team.update_attributes rank: rank
    end
  end

  # Summing all of the points the team has earned across their challenges
  def challenge_grade_score
    # use student_visible scope from challenge_grades
    challenge_grades.student_visible.sum("score") || 0
  end

  # Teams rack up points in two ways, which is used is determined by the
  # instructor in the course settings.
  # The first way is that the team's score is the average of its students'
  # scores, and challenge grades are added directly into students' scores.
  # The second way is that the teams compete in team challenges that earn
  # the team points.
  def set_challenge_grade_score
    self.challenge_grade_score = challenge_grade_score
  end

  def set_average_score
    self.average_score = average_points
  end

end
