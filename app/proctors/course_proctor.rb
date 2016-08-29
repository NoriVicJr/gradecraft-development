# determines what sort of CRUD operations can be performed
# on a `course` resource
class CourseProctor

  attr_reader :course

  def initialize(course)
    @course = course
  end

  def viewable?(user)
    return false if course.nil?
    user.courses.include? @course
  end

  def updatable?(user)
    return false if course.nil?
    user.is_professor?(course) || user.is_admin?(course)
  end

  def destroyable?(user)
    return false if course.nil?
    user.is_admin?(course)
  end
end
