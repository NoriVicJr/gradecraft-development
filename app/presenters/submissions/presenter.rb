require "./lib/showtime"

class Submissions::Presenter < Showtime::Presenter
  include Showtime::ViewContext

  def assignment
    @assignment = nil && return unless assignment_id
    @assignment ||= course.assignments.find assignment_id
  end

  def assignment_id
    properties[:assignment_id]
  end

  def course
    properties[:course]
  end

  def group
    return nil unless assignment.has_groups? and group_id
    @group ||= course.groups.find group_id
  end

  def group_id
    properties[:group_id]
  end
end
