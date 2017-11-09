class GoogleCalendars::AssignmentsController < ApplicationController
  include GoogleCalendarsHelper
  include OAuthProvider

  oauth_provider_param :google_oauth2
  require 'google/apis/calendar_v3'
  require 'google/api_client/client_secrets.rb'
  require 'googleauth'

  before_action do |controller|
    controller.redirect_path request.referer
  end

  before_action do |helper|
    helper.redirect_if_auth_not_present(current_user)
  end

  Calendar = Google::Apis::CalendarV3

  def add_assignment
    assignment = current_course.assignments.find(params[:id])
    if assignment.due_at.nil?
      # rubocop:disable AndOr
      redirect_to assignment_path(assignment), alert: "Google Calendar requires Assignment to have at least END time!" and return
    end
    event_hash = add_single_item(current_user, assignment)
    process_hash(event_hash)
  end

  def add_assignments
    assignment_list = get_all_items_for_current_course(current_course, "assignment", current_user)
    assignment_list_filtered = filter_items_with_no_end_date(assignment_list)
    assignments_hash = add_batch_items(current_user, assignment_list, assignment_list_filtered)
    assignments_hash.store("redirect_to", assignments_path)
    process_hash(assignments_hash)
  end

end
