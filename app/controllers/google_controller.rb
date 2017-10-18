class GoogleController < ApplicationController
  include OAuthProvider
  include GoogleCalendarsHelper

  oauth_provider_param :google_oauth2
  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action :load_from_activation_token
  skip_before_action :require_login, only: [:launch]
  skip_before_action :require_course_membership, only: [:launch]

  def launch
    binding.pry
    current_user = User.load_from_activation_token(params[:id]) if current_user.nil?
    redirect_if_auth_not_present
    auto_login current_user and redirect_to dashboard_path
  end

  def load_from_activation_token
    binding.pry
    if current_user.nil?
      @user = User.load_from_activation_token(params[:id])
      redirect_path launch_google_path(@user.activation_token)
    end
  end

end
