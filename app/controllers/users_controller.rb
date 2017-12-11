require_relative "../importers/user_importers/csv_student_importer"
require_relative "../services/cancels_course_membership"
require_relative "../services/creates_or_updates_user"
require 'uri'

class UsersController < ApplicationController
  include UsersHelper

  respond_to :html, :json

  before_action :ensure_admin?, only: [:index, :destroy]
  before_action :ensure_staff?,
    except: [:activate, :activated, :activated_external, :activate_set_password, :edit_profile, :update_profile, :new_external, :create_external]
  before_action :save_referer, only: [:manually_activate, :resend_activation_email]
  skip_before_action :require_login, only: [:activate, :activated, :activate_set_password, :new_external, :create_external, :activated_external]
  skip_before_action :require_course_membership, only: [:activate, :activate_set_password, :activated, :new_external, :create_external, :activated_external]
  before_action :use_current_course, only: [:import, :upload]

  def index
    @teams = current_course.teams
    @team = @teams.find_by(id: params[:team_id]) if params[:team_id]
    if params[:team_id].present?
      @users = @team.students
      @users << @team.leaders
    else
      @users = current_course.users.includes(:courses, :teams).order_by_name
    end
  end

  def new
    @user = User.new
    @course_membership = @user.course_memberships.new
    if request.referer.nil?
      @selected_role = 'observer'
    else
      case URI(request.referer).path
      when students_path
        @selected_role = 'student'
      when staff_index_path
        @selected_role = 'gsi'
      else
        @selected_role = 'observer'
      end
    end
  end

  # set up the form for users to create their own accounts without being logged
  # into the app
  def new_external
    if current_user.present?
      redirect_to new_user_path
    else
      @user = User.new
    end
  end

  # they've already set their passwords on the page, so they're just sent an
  # email prompting them to activate, and leading them to the next step in the process
  # creating a course
  def create_external
    @user = User.create(user_params)
    @user.username = user_params[:email]
    if @user.save
      UserMailer.activation_needed_course_creation_email(@user).deliver_now
      UserMailer.resources_email(@user).deliver_now
      redirect_to root_path, notice: "Your account has been created! Please check your email to activate your account."
    else
      redirect_to new_external_users_path
    end
  end

  def edit
    @user = User.find(params[:id])
    @course_membership = @user.course_memberships.where(course: current_course).first
  end

  def create
    if user_exists
      result = Services::CreatesOrUpdatesUser.create_or_update user_params, current_course,
        params[:send_welcome] == "1"
      @user = result[:user]

      if result.success?
        if @user.is_student?(current_course)
          redirect_to students_path,
            # rubocop:disable AndOr
            notice: "#{term_for :student} #{@user.name} was successfully created!" and return
        elsif @user.is_staff?(current_course)
          redirect_to staff_index_path,
            notice: "Staff Member #{@user.name} was successfully created!" and return
        elsif @user.is_observer?(current_course)
          redirect_to observers_path,
            notice: "Observer #{@user.name} was successfully created!" and return
        end
      end
    else
      @user = User.find_by_insensitive_email(params["user"]["email"])
    end

    if @user.course_memberships.where(course_id: current_course.id).first.nil?
      CourseMembershipBuilder.new(current_user).build_for(@user)
      render :new
    else
      if @user.is_student?(current_course)
        redirect_to students_path,
          # rubocop:disable AndOr
          alert: "#{term_for :student} #{params["user"]["first_name"]}
            #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      elsif @user.is_staff?(current_course)
        redirect_to staff_index_path,
          alert: "Staff Member #{params["user"]["first_name"]}
          #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      elsif @user.is_observer?(current_course)
        redirect_to observers_path,
          alert: "Observer #{params["user"]["first_name"]}
          #{params["user"]["last_name"]} with email #{params["user"]["email"]} already exists for #{current_course.name}!" and return
      end
    end
  end

  def update
    @user = User.find(params[:id])
    up = user_params
    if (up[:password].blank? && up[:password_confirmation].blank?) || !UserProctor.new(@user).can_update_password?(current_user, current_course)
      up.delete(:password)
      up.delete(:password_confirmation)
    end
    @user.assign_attributes up
    cancel_course_memberships @user
    if @user.save
      @user.activate! if up[:password].present? && !@user.activated?
      if @user.is_student?(current_course)
        redirect_to students_path, notice: "#{term_for :student} #{@user.name} was successfully updated!" and return
      elsif @user.is_staff?(current_course)
        redirect_to staff_index_path, notice: "Staff Member #{@user.name} was successfully updated!" and return
      elsif @user.is_observer?(current_course)
        redirect_to observers_path,
          notice: "Observer #{@user.name} was successfully updated!" and return
      end
    end

    CourseMembershipBuilder.new(current_user).build_for(@user)
    render :edit
  end

  def destroy
    @user = current_course.users.find(params[:id])
    @name = @user.name
    @user.destroy

    respond_to do |format|
      format.html do
        redirect_to users_url,
        notice: "#{@name} was successfully deleted"
      end
    end
  end

  # There are now two forms of activate - the first one just has the activate button
  def activate
    @user = User.load_from_activation_token(params[:id])
    @token = params[:id]
    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user
  end

  # ...and the second form actually has them set a new password. This is where
  # students who are imported/but not at UM are sent to set their info
  def activate_set_password
    @user = User.load_from_activation_token(params[:id])
    @token = params[:id]
    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user
  end

  def manually_activate
    @user = User.find(params[:id])
    @user.activate!
    redirect_to session[:return_to] || dashboard_path, notice: "#{@user.first_name} #{@user.last_name} has been activated!" and return
  end

  def activated
    @token = params[:token]
    @user = User.load_from_activation_token(@token)

    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user

    if @user.update_attributes user_params
      @user.activate!
      auto_login @user
      redirect_to dashboard_path, notice: "Welcome to GradeCraft!" and return
    end
    render :activate, alert: @user.errors.full_messages.first
  end

  # This is step #2 in the process of external users creating course shells - they
  # activate their account and then are sent on to a very basic Create a Course
  # form.
  def activated_external
    @token = params[:token]
    @user = User.load_from_activation_token(@token)

    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user

    if @user.save
      @user.activate!
      redirect_to new_external_courses_path(user_id: @user.id), notice: "Welcome to GradeCraft!" and return
    end
    render :activate, alert: @user.errors.full_messages.first
  end

  def flag
    @user = User.find(params[:id])
    FlaggedUser.toggle! current_course, current_user, @user.id
  end

  # We don't allow students to edit their info directly
  def edit_profile
    @user = current_user
    @course_membership =
      @user.course_memberships.where(course_id: current_course).first
  end

  def update_profile
    @user = current_user

    up = user_params
    if up[:password].blank? && up[:password_confirmation].blank?
      up.delete(:password)
      up.delete(:password_confirmation)
    end

    if @user.update_attributes(up)
      redirect_to dashboard_path,
        notice: "Your profile was successfully updated!"
    else
      @course_membership =
        @user.course_memberships.where(course_id: current_course).first
      render :edit_profile
    end
  end

  def import
  end

  # import users for class
  # rubocop:disable AndOr
  def upload
    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to users_path and return
    end

    if (File.extname params[:file].original_filename) != ".csv"
      redirect_to users_path, notice: "We're sorry, the user import utility only supports .csv files. Please try again using a .csv file." and return
    end

    @result = CSVStudentImporter.new(params[:file].tempfile,
                                     params[:internal_students] == "1",
                                     params[:send_welcome] == "1")
      .import(current_course)
    render :import_results
  end

  # resend invite email
  def resend_activation_email
    @user = User.find(params[:id])
    @user.setup_activation
    @user.save
    UserMailer.activation_needed_email(@user).deliver_now
    redirect_to session[:return_to] || dashboard_path, notice: "An Activation Email has been sent to #{@user.name}!"
  end

  def search
    @q = User.ransack params[:q]

    unless params[:q].nil?
      @result_size = @q.result.count
      @users = @q.result.includes(:course_memberships).limit(params[:max_results] || 50)
    end
  end

  private

  def user_exists
    if User.find_by_insensitive_email(params["user"]["email"]).nil?
      return true
    end

    user = User.find_by_insensitive_email(params["user"]["email"])

    if user.course_memberships.where(course_id: params["user"]["course_memberships_attributes"]["0"]["course_id"]).empty?
      return true
    end

    return false
  end

  def user_params
    params.require(:user).permit :username, :email, :admin, :password, :time_zone, :password_confirmation, :activation_token_expires_at, :activation_token,
      :activation_state, :avatar_file_name, :first_name, :last_name, :user_id,
      :kerberos_uid, :display_name, :current_course_id, :last_activity_at, :reset_password_email_sent_at, :reset_password_token_expires_at, :reset_password_token,
      :last_login_at, :last_logout_at, :team_ids, :course_ids, :remember_me_token_expires_at,
      :remember_me_token, :team_role, :team_id, :lti_uid, :course_team_ids, :internal,
      earned_badges_attributes: [:points, :feedback, :student_id, :badge_id,
        :submission_id, :course_id, :assignment_id, :level_id, :criterion_id, :grade_id,
        :student_visible, :id, :_destroy],
      course_memberships_attributes: [:auditing, :pseudonym, :character_profile, :course_id,
        :instructor_of_record, :user_id, :role, :last_login_at, :id, :team_role, :email_announcements, :email_badge_awards, :email_grade_notifications, :email_challenge_grade_notifications, :_destroy]
  end
end
