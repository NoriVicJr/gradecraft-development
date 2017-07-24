class AssignmentType < ActiveRecord::Base
  include Copyable
  include UnlockableCondition

  acts_as_list scope: :course

  belongs_to :course
  has_many :assignments, -> { order("position ASC") }, dependent: :destroy
  has_many :submissions, through: :assignments
  has_many :grades

  has_many :learning_objective_links, as: :learning_objective_linkable

  # This is the assignment weighting system (students decide how much
  # assignments will be worth for them)
  has_many :weights, class_name: "AssignmentTypeWeight", dependent: :destroy

  validates_presence_of :name
  validates :max_points, numericality: { greater_than: 0 }, allow_nil: true, length: { maximum: 9 }
  validates :top_grades_counted, numericality: { greater_than: -1 }, allow_nil: true, length: { maximum: 9 }

  scope :student_weightable, -> { where(student_weightable: true) }
  scope :with_submissions_this_week, -> { includes(:submissions).where("submissions.updated_at > ?", 7.days.ago).references(:submissions) }

  scope :ordered, -> { order("position ASC") }

  def copy(attributes={})
    ModelCopier.new(self).copy(attributes: attributes, associations: [:assignments])
  end

  # weights default to 0 if weightable but not weighted by the student
  def weight_for_student(student)
    return 1 unless student_weightable?
    weights.where(student: student).first.try(:weight) || 0
  end

  def is_capped?
    has_max_points? && max_points.present? && max_points > 0
  end

  # Checking to see if the instructor has set a maximum number of grades that
  # should count towards the assignment type score - always the highest ones
  def count_only_top_grades?
    top_grades_counted.present? && top_grades_counted > 0
  end

  # Getting the assignment types max value if it's present, else returning the
  # summed total of assignment points
  def total_points
    if is_capped?
      max_points
    else
      summed_assignment_points
    end
  end

  # Getting the assignment types max value if it's present and less than summed total, else
  # returning the summed total of assignment points
  def total_points_for_settings
    if is_capped?
      max_points > summed_assignment_points ? summed_assignment_points : max_points
    else
      summed_assignment_points
    end
  end

  # Calculating the total number of assignment points in the type
  def summed_assignment_points
    assignments.map{ |a| a.full_points || 0 }.sum
  end

  # total points a student can earn for this assignment type
  def total_points_for_student(student)
    if is_capped?
      max_points
    else
      if student_weightable?
        weighted_total_for_student(student)
      else
        summed_assignment_points
      end
    end
  end

  def weighted_total_for_student(student)
    total_points * weight_for_student(student)
  end

  def visible_score_for_student(student)
    if count_only_top_grades?
      return summed_highest_scores_for(student)
    elsif is_capped?
      return max_points_for_student(student)
    else
      return score_for_student(student)
    end
  end

  def grades_for(student)
    student.grades.student_visible
                  .not_nil
                  .included_in_course_score
                  .where(assignment_type: self)
  end

  def count_grades_for(student)
    grades_for(student).count
  end

  def score_for_student(student)
    grades_for(student).pluck("score").sum || 0
  end

  def raw_points_for_student(student)
    grades_for(student).pluck("raw_points").sum || 0
  end

  def final_points_for_student(student)
    grades_for(student).pluck("final_points").sum || 0
  end

  # Calculating what the total highest points for the type is for a student
  def summed_highest_scores_for(student)
    if self.count_only_top_grades?
      score = grades_for(student)
                    .order_by_highest_score
                    .first(top_grades_counted).sum(&:score) || 0
      return max_points if is_capped? && (score > max_points)
      score
    end
  end

  def max_points_for_student(student)
    score = score_for_student(student)
    return max_points if is_capped? && score > max_points
    score
  end
end
