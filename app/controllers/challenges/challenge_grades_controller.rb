class Challenges::ChallengeGradesController < ApplicationController
  before_filter :ensure_staff?

  before_action :find_challenge, only: [:new, :create, :mass_edit, :mass_update,
    :edit_status, :update_status ]

  # GET /challenges/:challenge_id/challenge_grade?team_id=:team_id
  def new
    @team = current_course.teams.find(params[:team_id])
    @challenge_grade = ChallengeGrade.new
    @title = "Grading #{@team.name}'s #{@challenge.name}"
  end

  # POST /challenge_grades
  def create
    @challenge_grade = current_course.challenge_grades.new(params[:challenge_grade])
    @team = @challenge_grade.team
    if @challenge_grade.save

      if ChallengeGradeProctor.new(@challenge_grade).viewable?
        ChallengeGradeUpdaterJob.new(challenge_grade_id: @challenge_grade.id).enqueue
      end

      redirect_to @challenge,
        notice: "#{@team.name}'s Grade for #{@challenge.name} #{(term_for :challenge).titleize} successfully graded"
    else
      render action: "new"
    end
  end

  # Grade many teams on a particular challenge at once
  # GET /challenges/:challenge_id/challenge_grades/mass_edit
  def mass_edit
    @title = "Quick Grade #{@challenge.name}"
    @teams = current_course.teams
    @challenge_grades = @teams.map { |t| @challenge.challenge_grades.find_or_initialize_for_team(t) }
  end

  # PUT /challenges/:id/challenge_grades/mass_update
  def mass_update
    if @challenge.update_attributes(params[:challenge])

      challenge_grade_ids = []
      @challenge.challenge_grades.each do |challenge_grade|
        if challenge_grade.previous_changes[:score].present?
          challenge_grade_ids << challenge_grade.id
        end
      end

      challenge_grade_ids.each { |id| ChallengeGradeUpdaterJob.new(challenge_grade_id: id).enqueue }

      redirect_to challenge_path(@challenge),
        notice: "#{@challenge.name} #{term_for :challenge} successfully graded"
    else
      render action: "mass_edit"
    end
  end

  # Changing the status of a grade - allows instructors to review "Graded"
  # grades, before they are "Released" to students
  # GET /challenges/:challenge_id/challenge_grades/edit_status
  def edit_status
    @title = "#{@challenge.name} Grade Statuses"
    @challenge_grades =
      @challenge.challenge_grades.find(params[:challenge_grade_ids])
  end

  # PUT /challenges/:challenge_id/challenge_grades/update_status
  def update_status
    @challenge_grades =
      @challenge.challenge_grades.find(params[:challenge_grade_ids])
    @challenge_grades.each do |challenge_grade|
      challenge_grade.update_attributes!(params[:challenge_grade].reject { |k, v| v.blank? })
    end
    flash[:notice] = "Updated #{(term_for :challenge).titleize} Grades!"
    redirect_to challenge_path(@challenge)
  end

  private

  def find_challenge
    @challenge = current_course.challenges.find(params[:challenge_id])
  end
end