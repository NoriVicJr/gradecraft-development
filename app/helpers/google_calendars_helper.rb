require 'google/apis/calendar_v3'
require 'google/api_client/client_secrets.rb'
require 'googleauth'

module GoogleCalendarsHelper
  Calendar = Google::Apis::CalendarV3

  def redirect_if_auth_not_present(current_user)
    # rubocop:disable AndOr
    redirect_to "/auth/google_oauth2?prompt=consent" and return unless google_auth_present?(current_user)
  end

  def get_google_authorization(current_user)
    google_authorization = current_user.authorizations.find_by(provider: "google_oauth2")
    refresh_if_google_authorization_is_expired(google_authorization)
    google_authorization
  end

  def get_all_items_for_current_course(current_course, class_name, current_user)
    return current_course.events if class_name == "event"
    return current_course.assignments if class_name == "assignment" && current_user.is_staff?(current_course)
    return retrieve_visible_assignments(current_course, current_user) if class_name == "assignment" && !current_user.is_staff?(current_course)
  end

  def retrieve_visible_assignments(current_course, current_user)
    assignments = []
    current_course.assignments.each do |assignment|
      assignments.append(assignment) if assignment.visible_for_student?(current_user)
    end
    return assignments
  end

  def filter_items_with_no_end_date(item_list)
    list = []
    item_list.each do |item|
      if !item.due_at.nil?
        list.append(item)
      end
    end
    return list
  end

  def refresh_if_google_authorization_is_expired(google_authorization)
    return unless google_authorization.expired?
    google_authorization.refresh!({ client_id: ENV["GOOGLE_CLIENT_ID"], client_secret: ENV["GOOGLE_SECRET"] })
  end

  def google_auth_present?(current_user)
    current_user.authorizations.find_by(provider: "google_oauth2").present?
  end

  def create_google_event(item)
    google_event = Calendar::Event.new({
      summary: item.name,
      description: item.description,
      start: {
        date_time: (generate_open_date_if_one_does_not_exist(item)).to_datetime.rfc3339
      },
      end: {
        date_time: item.due_at.to_datetime.rfc3339
      }
    })
    google_event
  end

  def generate_open_date_if_one_does_not_exist(item)
    if item.open_at.nil?
      item.due_at - 30.minutes
    else
      item.open_at
    end
  end

  def refresh_google_calendar_authorization(current_user)
    calendar = Calendar::CalendarService.new
    client_id = Google::Auth::ClientId.new(ENV['GOOGLE_CLIENT_ID'], ENV['GOOGLE_SECRET'])
    secrets = create_google_secrets(get_google_authorization(current_user))
    calendar.authorization = secrets.to_authorization
    calendar.authorization.refresh!
    return calendar
  end

  def create_google_secrets(google_authorization)
    Google::APIClient::ClientSecrets.new({"web" =>
      {"access_token" => google_authorization.access_token,
        "refresh_token" => google_authorization.refresh_token,
        "client_id" => ENV['GOOGLE_CLIENT_ID'],
        "client_secret" => ENV['GOOGLE_SECRET']}
        })
  end

  def add_single_item(current_user, item)
    begin
      add(current_user, item)
      return {"redirect_to" => item, "message_type" => "notice", "message" => "Item " + item.name + " successfully added to your Google Calendar"}
    rescue Signet::AuthorizationError
      return {"redirect_to" => "/auth/google_oauth2?prompt=consent"}
    rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError
      return {"redirect_to" => item, "message_type" => "alert", "message" => "Google Calendar encountered an Error. Your " + item.class.name + " was NOT copied to your Google calendar."}
    end
  end

  # note: if there is a server error during a batch process the items processed before the server error will be copied to the associated google calendar
  def add_batch_items(current_user, item_list, item_list_filtered)
    begin
      calendar = refresh_google_calendar_authorization(current_user)
      calendar.batch do |batch|
        item_list_filtered.each do |item|
          batch.insert_event('primary', create_google_event(item))
        end
      end
      return {"message_type" => "notice", "message" => "#{item_list_filtered.count} item(s) successfully added to your Google Calendar"} unless item_list.count != item_list_filtered.count
      return {"message_type" => "notice", "message" => "#{item_list_filtered.count} item(s) successfully added to your Google Calendar. #{item_list.count - item_list_filtered.count} item(s) were not added because of missing due date(s)."}
    rescue Signet::AuthorizationError
      return {"redirect_to" => "/auth/google_oauth2?prompt=consent"}
    rescue Google::Apis::ServerError, Google::Apis::ClientError, Google::Apis::AuthorizationError
      return {"message_type" => "alert", "message" => "Google Calendar encountered an Error. Your item was NOT copied to your Google calendar."}
    end
  end

  def add(current_user, item)
    calendar = refresh_google_calendar_authorization(current_user)
    calendar.insert_event('primary', create_google_event(item))
  end

  def process_hash(hash)
    if hash["message_type"] == "alert"
      redirect_to hash["redirect_to"], alert: hash["message"] and return
    else
      redirect_to hash["redirect_to"], notice: hash["message"] and return
    end
  end

  def load_from_activation_token
    return unless current_user.nil? && !params[:id].nil?
    @user = User.load_from_activation_token(params[:id])
  end

end
