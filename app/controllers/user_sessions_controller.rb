class UserSessionsController < ApplicationController

  skip_before_filter :require_login, :except => [:destroy, :new, :index]
  skip_before_filter :verify_authenticity_token, :only => [:lti_create]

  def new
    @user = User.new
  end

  def create
    respond_to do |format|
      if @user = login(params[:user][:email],params[:user][:password],params[:user][:remember_me])
        format.html { redirect_back_or_to dashboard_path }
        format.xml { render :xml => @users, :status => :created, :location => @user }
      else
        @user = User.new
        format.html { flash.now[:error] = "Login failed."; render :action => "new" }
        format.xml { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end

  def lti_create
    @user = User.find_or_create_by_lti_auth_hash(auth_hash)
    @course = Course.find_by_lti_uid(auth_hash['extra']['raw_info']['context_id'])
    if !@user || !@course
      lti_error_notification
      redirect_to lti_error_path
      return
    end
    @user.courses << @course unless @user.courses.include?(@course)
    save_lti_context
    auto_login @user
    flash[:notice] = t('sessions.lti.success')
    respond_with @user, :location => dashboard_path
  end

  def destroy
    logout
    redirect_to 'root', :notice => "Logged out!"
  end

  private

  def auth_hash
    request.env['omniauth.auth']
  end

  def lti_error_notification
    info = auth_hash['info']
    user = { name: "#{info['first_name']} #{info['last_name']}", email: info['email'], uid: auth_hash['uid'] }
    course = { name: auth_hash['extra']['context_label'], uid: auth_hash['extra']['context_id'] }
    NotificationMailer.lti_error(user, course).deliver
  end
end
