class AuthorizationsController < ApplicationController

  skip_before_action :require_login, only: [:create]
  skip_before_action :require_course_membership, only: [:create]
  before_action :log_me_in, only: [:create]

  def create
    UserAuthorization.create_by_auth_hash request.env["omniauth.auth"], current_user

    return_to = session[:return_to]
    session[:return_to] = nil
    redirect_to return_to || root_path
  end

  def log_me_in
    auto_login User.find_by_email(request.env["omniauth.auth"]["info"]["email"]) if current_user.nil?
  end
end
