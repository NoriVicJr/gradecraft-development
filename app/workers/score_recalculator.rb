class ScoreRecalculatorPerformer < ResqueJob::Performer
  def setup
    @student_id = @attrs[:student_id]
    @course_id = @attrs[:course_id]
    @student = fetch_student
  end

  # perform() attributes assigned to @attrs in the ResqueJob::Base class
  def do_the_work
    # TODO: write model specs for cache_course_score outcomes
    require_success(messages) { @student.cache_course_score(@course_id) }
  end

  protected

  def messages
    {
      success: "Successfully cached student ##{@student.id}'s score for course ##{@course_id}",
      failure: "Failed to cache student ##{@student.id}'s score for course ##{@course_id}"
    }
  end

  def fetch_student
    User.find(@student_id)
  end
end

# TODO: add specs for all of these
class ScoreRecalculatorJob < ResqueJob::Base
  @queue = :score_recalculator
  @performer_class = ScoreRecalculatorPerformer
end
