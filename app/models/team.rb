class Team < ActiveRecord::Base
  include Copyable

  validates_presence_of :course, :name
  validates :name, uniqueness: { case_sensitive: false, scope: :course_id }

  # Teams belong to a single course
  belongs_to :course

  has_many :team_memberships
  has_many :students, through: :team_memberships, autosave: true
  has_many :team_leaderships
  has_many :leaders, through: :team_leaderships

  # Teams design banners that they display on the leadboard
  mount_uploader :banner, BannerUploader

  # Teams don't currently earn badges directly - but they are recognized for
  # the badges their students earn
  has_many :earned_badges, through: :students

  # Teams compete through challenges, which earn points through challenge_grades
  has_many :challenge_grades
  has_many :challenges, through: :challenge_grades

  accepts_nested_attributes_for :team_memberships

  # Various ways to sort the display of teams
  scope :order_by_average_score, -> { order("average_score DESC") }
  scope :order_by_challenge_grade_score, -> { order("challenge_grade_score DESC")}
  scope :order_by_rank, -> { order("rank ASC")}
  scope :alpha, -> { order("name ASC") }

  def self.find_by_course_and_name(course_id, name)
    where(course_id: course_id)
      .where("LOWER(name) = :name", name: name.downcase).first
  end

  def copy(attributes={}, lookup_store=nil)
    ModelCopier.new(self, lookup_store).copy(
      attributes: attributes.merge(challenge_grade_score: nil, average_score: 0),
      associations: [{ team_memberships: { team_id: :id }}],
      options: { lookups: [:courses] }
    )
  end

  def active_members
    students.students_being_graded_for_course(course, self)
  end

  # How many badges the students on the team have earned total
  def badge_count
    earned_badges.where(course_id: self.course_id).student_visible.count
  end

  # The number of points all students have earned total
  def total_earned_points
    total_score = 0
    active_members.each do |student|
      total_score += (student.score_for_course(course) || 0 )
    end
    return total_score
  end

  # The average points amongst all students on the team
  def calculate_average_score
    return 0 unless active_members.count > 0
    average_score = total_earned_points / active_members.count
  end

  def sorted_team_scores
    teams = course.teams
    if course.team_score_average?
      rank_index = teams.order_by_average_score.pluck('average_score')
    elsif course.challenges.present?
      rank_index = teams.order_by_challenge_grade_score.pluck('challenge_grade_score')
    end
    return rank_index
  end

  def score
    if course.team_score_average?
      average_score
    elsif course.challenges.present?
      challenge_grade_score
    end
  end

  def update_ranks!
    course.teams.each do |team|
      if course.team_score_average?
        rank = sorted_team_scores.index(team.average_score) + 1
      elsif course.challenges.present?
        rank = (sorted_team_scores.index(team.challenge_grade_score) || 0) + 1
      end
      team.update_attributes rank: rank
    end
  end

  # Summing all of the points the team has earned across their challenges
  def challenge_grade_score
    # use student_visible scope from challenge_grades
    challenge_grades.student_visible.sum("final_points") || 0
  end

  # Teams rack up points in two ways, which is used is determined by the
  # instructor in the course settings.
  # The first way is that the team's score is the average of its students'
  # scores, and challenge grades are added directly into students' scores.
  # The second way is that the teams compete in team challenges that earn
  # the team points.
  def update_challenge_grade_score!
    self.update_attributes challenge_grade_score: challenge_grade_score
  end

  def update_average_score!
    self.update_attributes average_score: calculate_average_score
  end

end
