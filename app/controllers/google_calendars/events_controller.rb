class GoogleCalendars::EventsController < ApplicationController
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

  def add_event
    event = current_course.events.find(params[:id])
    if event.due_at.nil?
      # rubocop:disable AndOr
      redirect_to event_path(event), alert: "Google Calendar requires Event to have at least END time!" and return
    end
    event_hash = add_single_item(current_user, event)
    process_hash(event_hash)
  end

  def add_events
    event_list = get_all_items_for_current_course(current_course, "event", current_user)
    event_list_filtered = filter_items_with_no_end_date(event_list)
    events_hash = add_batch_items(current_user, event_list, event_list_filtered)
    events_hash.store("redirect_to", events_path)
    process_hash(events_hash)
  end

end
