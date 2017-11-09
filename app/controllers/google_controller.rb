class GoogleController < ApplicationController
  include OAuthProvider
  include GoogleCalendarsHelper

  # oauth_provider_param :google_oauth2

  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action :load_from_activation_token
  skip_before_action :require_login, only: [:launch_from_activation_token, :launch_from_login]
  skip_before_action :require_course_membership, only: [:launch_from_activation_token, :launch_from_login]

  def launch_from_activation_token
    # rubocop:disable AndOr
    current_user = User.load_from_activation_token(params[:id]) if current_user.nil?
    redirect_if_auth_not_present(current_user)
    auto_login current_user and redirect_to dashboard_path
  end

  def launch_from_login
    redirect_to "/auth/google_oauth2" and return
  end

end
