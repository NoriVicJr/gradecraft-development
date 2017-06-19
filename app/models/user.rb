class User < ActiveRecord::Base
  include Analytics::UserAnalytics

  authenticates_with_sorcery!

  class << self
    def with_role_in_course(role, course)
      if role == "staff"
        user_ids = CourseMembership.where("course_id=? AND (role=? OR role=?)", course, "professor", "gsi").pluck(:user_id)
      else
        user_ids = CourseMembership.where(course: course, role: role).pluck(:user_id)
      end
      User.where(id: user_ids)
    end

    Role.all.each do |role|
      define_method(role.pluralize) do |course|
        with_role_in_course(role,course)
      end
    end

    def students_for_course(course, team=nil)
      user_ids = CourseMembership.where(course: course, role: "student").pluck(:user_id)
      query = User.where(id: user_ids)
      query = query.students_in_team(team.id, user_ids) if team
      query
    end

    def active_students_for_course(course, team=nil)
      user_ids = CourseMembership.where(course: course, role: "student", active: true).pluck(:user_id)
      query = User.where(id: user_ids)
      query = query.students_in_team(team.id, user_ids) if team
      query
    end

    def students_being_graded_for_course(course, team=nil)
      user_ids = CourseMembership.where(course: course, role: "student", auditing: false, active: true).pluck(:user_id)
      query = User.where(id: user_ids)
      query = query.students_in_team(team.id, user_ids) if team
      query
    end

    def internal_email_regex
      /(\.|@)umich\.edu$/
    end
  end

  attr_accessor :password, :password_confirmation, :score, :team

  ransack_alias :name, :first_name_or_last_name

  scope :order_by_high_score, -> (course_id) { includes(:course_memberships).where(course_memberships: { course_id: course_id }).order "course_memberships.score DESC" }
  scope :order_by_low_score, -> (course_id) { includes(:course_memberships).where(course_memberships: { course_id: course_id }).order "course_memberships.score ASC" }
  scope :students_in_team, -> (team_id, student_ids) \
    { includes(:team_memberships).where(team_memberships: { team_id: team_id, student_id: student_ids }) }

  scope :order_by_name, -> { order("last_name, first_name ASC") }

  scope :accounts_not_activated, ->(course_id) { includes(:course_memberships).where(course_memberships: { course_id: course_id }, activation_state: 'pending')}

  mount_uploader :avatar_file_name, AvatarUploader

  has_many :authorizations, class_name: "UserAuthorization", dependent: :destroy
  has_many :course_memberships, dependent: :destroy, inverse_of: :user
  has_many :courses, through: :course_memberships
  has_many :course_users, through: :courses, source: "users"
  accepts_nested_attributes_for :courses
  accepts_nested_attributes_for :course_memberships, allow_destroy: true

  belongs_to :current_course, class_name: "Course", touch: true

  has_many :assignments, through: :grades

  has_many :unlock_states, foreign_key: :student_id, dependent: :destroy

  has_many :assignment_type_weights, foreign_key: :student_id

  has_many :submissions, foreign_key: :student_id, dependent: :destroy
  has_many :created_submissions, as: :creator

  has_many :grades, foreign_key: :student_id, dependent: :destroy
  has_many :predicted_earned_grades, foreign_key: :student_id, dependent: :destroy
  has_many :predicted_earned_badges, foreign_key: :student_id, dependent: :destroy
  has_many :predicted_earned_challenges, foreign_key: :student_id, dependent: :destroy
  has_many :graded_grades, foreign_key: :graded_by_id, class_name: "Grade"
  has_many :criterion_grades, foreign_key: :student_id, dependent: :destroy

  has_many :imported_users, dependent: :destroy

  has_many :earned_badges, foreign_key: :student_id, dependent: :destroy
  has_many :awarded_badges, foreign_key: :awarded_by_id, class_name: 'EarnedBadge'

  accepts_nested_attributes_for :earned_badges, reject_if: proc { |attributes| attributes["earned"] != "1" }
  has_many :badges, through: :earned_badges

  has_many :group_memberships, foreign_key: :student_id, dependent: :destroy
  has_many :groups, through: :group_memberships
  has_many :assignment_groups, through: :groups

  has_many :team_memberships, foreign_key: :student_id, dependent: :destroy
  has_many :team_leaderships, foreign_key: :leader_id, dependent: :destroy
  has_many :teams, through: :team_memberships do
    def set_for_course(course_id, ids)
      other_team_ids = proxy_association.owner.teams.where("course_id != ?", course_id).pluck(:id)
      if proxy_association.owner.role(Course.find(course_id)) == "student"
        proxy_association.owner.team_ids = other_team_ids | [ids]
      else
        if ids.present?
          proxy_association.owner.team_ids = other_team_ids | ids
        end
      end
    end
  end

  email_regex = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i

  validates :username, presence: true,
                    length: { maximum: 50 },
                    uniqueness: { case_sensitive: false }
  validates :email, presence: true,
                    format: { with: email_regex },
                    uniqueness: { case_sensitive: false }

  validates :first_name, :last_name, presence: true
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, if: :password, on: :update
  validates :email, internal_email: { format: internal_email_regex, name: "University of Michigan" }

  def internal?
    @internal || email_was =~ self.class.internal_email_regex
  end

  def internal=(value)
    @internal = value
  end

  def self.find_by_kerberos_auth_hash(auth_hash)
    where(kerberos_uid: auth_hash["uid"]).first
  end

  def self.find_by_insensitive_email(email)
    where("LOWER(email) = :email", email: (email || "").downcase).first
  end

  def self.find_by_insensitive_username(username)
    where("LOWER(username) = :username", username: (username || "").downcase).first
  end

  def self.find_by_insensitive_last_name(last_name)
    where("LOWER(last_name) = :last_name", last_name: (last_name || "").downcase)
  end

  def self.find_by_insensitive_first_name(first_name)
    where("LOWER(first_name) = :first_name", first_name: (first_name || "").downcase)
  end

  def self.find_by_insensitive_full_name(first_name, last_name)
    where("LOWER(first_name) = :first_name and LOWER(last_name) = :last_name",
      first_name: (first_name || "").downcase,
      last_name: (last_name || "").downcase)
  end

  def self.email_exists?(email)
    !!find_by_insensitive_email(email)
  end

  def activated?
    activation_state == "active"
  end

  def name
    @name = [first_name,last_name].reject(&:blank?).join(" ").presence || "User #{id}"
  end

  def display_name(course)
    course_memberships.where(course: course).first.try(:pseudonym)
  end

  def team_role(course)
    course_memberships.where(course: course).first.team_role
  end

  def email_badge_awards?(course)
    return true if course_memberships.where(course: course).first.email_badge_awards?
  end

  def email_grade_notifications?(course)
    return true if course_memberships.where(course: course).first.email_grade_notifications?
  end

  def email_announcements?(course)
    return true if course_memberships.where(course: course).first.email_announcements?
  end

  def email_challenge_grade_notifications?(course)
    return true if course_memberships.where(course: course).first.email_challenge_grade_notifications?
  end

  def submitter_directory_name
    "#{last_name.camelize}, #{first_name.camelize}"
  end

  def submitter_directory_name_with_suffix
    "#{submitter_directory_name} - #{username.downcase}"
  end

  def same_name_as?(another_user)
    name.downcase == another_user.name.downcase
  end

  Role.all.each do |role|
    define_method("is_#{role}?") do |course|
      self.role(course) == role
    end
  end

  def role(course)
    return "admin" if self.admin?
    membership = self.course_memberships.where(course_id: course.id).first
    membership.role if membership
  end

  def is_staff?(course)
    is_professor?(course) || is_gsi?(course) || is_admin?(course)
  end

  ### TEAMS
  # Finding a student's team for a course
  def team_for_course(course)
    @team ||= teams.where(course_id: course).first
  end

  # Finding all of the team leaders for a single team
  def team_leaders(course)
    @team_leaders ||= team_for_course(course).leaders rescue nil
  end

  # Finding all of a team leader's teams for a single course
  def team_leaderships_for_course(course)
    team_leaderships.joins(:team).where("teams.course_id = ?", course.id)
  end

  # Space for users to build a narrative around their identity
  def character_profile(course)
    course_memberships.where(course: course).first.try("character_profile")
  end

  def archived_courses
    courses.where(status: false)
  end

  # PREDICTIONS

  # Checking to see if a student has any positive predictions for a course
  def predictions_for_course?(course)
    predicted_earned_grades.for_course(course).predicted_to_be_done.present?
  end

  ### GRADES

  # Checking specifically if there is a student visible grade for an assignment
  def grade_visible_for_assignment?(assignment)
    grade = grade_for_assignment(assignment)
    grade.student_visible?
  end

  def grades_for_course(course)
    grades.where(course: course)
  end

  # Grabbing the grade for an assignment
  def grade_for_assignment(assignment)
    grades.where(assignment_id: assignment.id).first || grades.new(assignment: assignment)
  end

  def grade_for_assignment_id(assignment_id)
    grades.where(assignment_id: assignment_id)
  end

  # Powers the worker to recalculate student scores
  def update_course_score_and_level(course_id)
    membership = course_memberships.where(course_id: course_id).first
    return unless membership.present?
    membership.recalculate_and_update_student_score
    membership.check_and_update_student_earned_level
  end

  ### SUBMISSIONS

  def submission_for_assignment(assignment, submitted_only=true)
    if self.has_group_for_assignment?(assignment)
      self.group_for_assignment(assignment).submission_for_assignment(assignment, submitted_only)
    else
      user_submissions = submitted_only ? submissions.submitted : submissions
      user_submissions.where(assignment_id: assignment.id).try(:first)
    end
  end

  ### BADGES

  def earned_badges_for_course(course)
    earned_badges.where(course: course).student_visible
  end

  # includes badges not yet visible to students
  def awarded_badges_for_badge(badge)
    earned_badges.where(badge: badge)
  end

  # includes badges not yet visible to students
  def awarded_badges_for_badge_count(badge)
    earned_badges.where(badge: badge).count
  end

  # Unique badges associated with all of the earned badges for a given
  # student/course combo
  def unique_student_earned_badges(course)
    @unique_student_earned_badges ||= Badge
      .includes(:earned_badges)
      .where("earned_badges.course_id = ?", course[:id])
      .where("earned_badges.student_id = ?", self[:id])
      .where("earned_badges.student_visible = ?", true)
      .references(:earned_badges)
  end

  # Student visible earned badges for a particular badge
  def earned_badges_for_badge(badge)
    EarnedBadge
      .where(badge: badge)
      .where(student_id: self.id)
      .where(student_visible: true)
  end

  # Number of times a student has earned a particular badge
  def earned_badges_for_badge_count(badge)
    self.earned_badges_for_badge(badge).count
  end

  # this should be all earned badges that either:
  # 1) have no associated grade and have been awarded to the student, or...
  # 2) have an associated grade that is student visible
  def student_visible_earned_badges(course)
    @student_visible_earned_badges ||= EarnedBadge
      .includes(:badge)
      .where(course: course)
      .where(student_id: self[:id])
      .where(student_visible: true)
  end

  # this should be all badges that:
  # 1) exist in the current course, in which the student is enrolled, AND:
  # 2) the student has either not earned at all for any grade, or:
  # 3) the student has earned the badge, but multiple are allowed, or:
  # 3) the student has earned the badge, multiple are not allowed, but the
  # earned badge is for the current grade
  def earnable_course_badges_for_grade(grade)
    Badge
      .where(course_id: grade[:course_id])
      .merge(earnable_course_badges(grade))
  end

  # this should be all badges that:
  # 1) exist in the current course, in which the student is enrolled
  # 2) the student has not earned, but is visible & available, or...
  # 3) the student has earned_badge for, but that earned_badge is set to
  # student_visible 'false' <- I think this is incorrect? @ch
  def student_visible_unearned_badges(course)
    Badge
      .where(course_id: course[:id])
      .where(visible: true)
      .where("id not in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ? and earned_badges.student_visible = ?)", self[:id], course[:id], true)
  end

  # WEIGHTS

  # Returns the student's assigned weight for an assignment type category
  def weight_for_assignment_type(assignment_type)
    assignment_type_weights.where(assignment_type: assignment_type).first.try(:weight) || 0
  end

  def weight_spent?(course)
    return true if self.total_weight_spent(course) == course.total_weights
    return false
  end

  def total_weight_spent(course)
    total = 0
    course.assignment_types.student_weightable.each do |assignment_type|
      total += self.weight_for_assignment_type(assignment_type)
    end
    return total
  end

  def weighted_assignments?(course)
    assignment_type_weights.where(course: course).count > 0
  end

  # Used to allow students to self-log a grade
  def self_reported_done?(assignment)
    grade = grade_for_assignment(assignment)
    GradeProctor.new(grade).viewable?
  end

  ### GROUPS

  def group_for_assignment(assignment)
    assignment_groups.where(assignment: assignment).first.try(:group)
  end

  def has_group_for_assignment?(assignment)
    assignment.has_groups? && group_for_assignment(assignment).present?
  end

  def last_course_login(course)
    course_memberships.where(course: course).first.last_login_at
  end

  def formatted_long_name
    if email.present?
      "#{self.name} #{self.email}"
    else
      "#{self.name}"
    end
  end

  def searchable_name
    "#{ formatted_long_name}"
  end

  private

  def earnable_course_badges(grade)
    Badge
      .unscoped
      .where("(id not in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ?))", self[:id], grade[:course_id])
      .or(Badge.where("(id in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ?) and can_earn_multiple_times = ?)", self[:id], grade[:course_id], true))
      .or(Badge.where("(id in (select distinct(badge_id) from earned_badges where earned_badges.student_id = ? and earned_badges.course_id = ? and earned_badges.grade_id = ?) and can_earn_multiple_times = ?)", self[:id], grade[:course_id], grade[:id], false))
  end
end
