class AuthorizationsController < ApplicationController

  skip_before_action :require_login, only: [:create_for_google]
  skip_before_action :require_course_membership, only: [:create_for_google]
  before_action :require_authorization, only: [:log_me_in]
  before_action :log_me_in, only: [:create_for_google]

  def create_for_google
    # rubocop:disable AndOr
    UserAuthorization.create_by_auth_hash request.env["omniauth.auth"], current_user

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to, notice: "GradeCraft now has access to your Calendar, please try to add your item again." and return unless return_to.nil?
    redirect_to root_path
  end

  def create
    UserAuthorization.create_by_auth_hash request.env["omniauth.auth"], current_user

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  private

  def log_me_in
    begin
      auto_login User.find_by_email(request.env["omniauth.auth"]["info"]["email"]) if current_user.nil?
    rescue
      redirect_to auth_failure_path
    end
  end
end
