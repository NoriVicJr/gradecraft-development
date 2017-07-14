# rubocop:disable AndOr
class AttendanceController < ApplicationController
  before_action :ensure_staff?, except: :index
  before_action :ensure_has_events?, only: :index
  before_action :find_or_create_assignment_type, except: :index

  # GET /attendance
  def index
    @assignments = current_course.assignments.with_attendance_type
    if current_user_is_student? || current_user_is_observer?
      render "assignments/index", Assignments::StudentPresenter.build({
        student: current_student,
        assignment_types: current_course.assignment_types.attendance.ordered.includes(:assignments),
        course: current_course,
        view_context: view_context
      })
    end
  end

  # GET /attendance/new
  def new
    @assignment = Assignment.new
  end

  # POST /attendance
  def create
    assignment = current_course.assignments.new attendance_assignment_params

    if assignment.save
      redirect_to attendance_index_path,
        notice: "#{assignment.name} successfully created" and return
    else
      render :new
    end
  end

  # POST /attendance/setup
  def setup
    redirect_to action: :index and return if has_attendance_events?
  end

  private

  def attendance_assignment_params
    params.require(:assignment).permit :assignment_type_id, :name, :description,
      :open_at, :due_at, :pass_fail, :full_points
  end

  def find_or_create_assignment_type
    @assignment_type = AssignmentType.attendance_type_for current_course
    @assignment_type = current_course.assignment_types.create(attendance: true, name: "Attendance") if @assignment_type.nil?
  end

  def ensure_has_events?
    if !has_attendance_events?
      redirect_to action: :setup and return if current_user_is_staff?
      redirect_to dashboard_path
    end
  end

  def has_attendance_events?
    current_course.assignments.with_attendance_type.any?
  end
end
