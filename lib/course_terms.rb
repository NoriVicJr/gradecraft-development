module CourseTerms
  def self.included(base)
    base.helper_method :term_for if base < ActionController::Base
  end

  def term_for(key, fallback = nil)
    case key.downcase.to_sym
    when :learning_objective then current_course.learning_objective_term.singularize
    when :student then current_course.student_term.to_s.singularize
    when :grade_predictor then current_course.grade_predictor_term.to_s.singularize  
    when :weight, :assignment, :badge, :team, :team_leader, :group
      current_course.send("#{key}_term").to_s.singularize
    when :pass, :fail
      current_course.send("#{key.downcase}_term").to_s
    when :challenge then "#{term_for(:team)} #{current_course.challenge_term}"
    when :assignment_type then "#{term_for(:assignment)} type"
    when :students, :weights, :assignments, :assignment_types, :teams, :team_leaders, :badges, :challenges, :groups, :learning_objectives
      term_for(key.to_s.downcase.singularize).pluralize
    else
      fallback.presence || raise("No term defined for :#{key} Please define one in lib/course_terms.rb.")
    end
  end
end
