require "./lib/showtime"

class Info::DashboardCourseRulesPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def term_for_assignments?
    course.assignment_term != "Assignment"
  end

  def term_for_badges?
    course.has_badges? && course.badge_term != "Badge"
  end

  def term_for_teams?
    course.has_teams? && course.team_term != "Team"
  end

  def term_for_team_leaders?
    course.has_teams? && course.team_leader_term != "TA"
  end

  def term_for_groups?
    course.group_term != "Group"
  end

  def term_for_weights?
    course.weight_term != "Multiplier"
  end

  def term_for_challenges?
    course.has_team_challenges? && course.challenge_term != "Challenge"
  end

  def has_course_terminology?
    [term_for_assignments?, term_for_badges?, term_for_teams?, term_for_team_leaders?, term_for_challenges?, term_for_groups?, term_for_weights?].any?
  end

  def has_course_specific_features?
    [course.has_badges?, course.teams_visible?, course.has_multipliers?, has_course_terminology?].any?
  end
end 
