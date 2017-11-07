require_relative "active_lms"

Rails.application.config.middleware.use OmniAuth::Builder do
  provider :canvas, ActiveLMS.configuration.providers[:canvas].client_id,
    ActiveLMS.configuration.providers[:canvas].client_secret, setup: true
  provider :developer unless Rails.env.production?
  provider :google_oauth2, ENV["GOOGLE_CLIENT_ID"], ENV["GOOGLE_SECRET"],
    scope: 'profile, email, calendar', include_granted_scopes: true, select_account: true, access_type: 'offline'
  provider :lti, :oauth_credentials => { ENV["LTI_CONSUMER_KEY"] => ENV["LTI_CONSUMER_SECRET"] }
  provider :kerberos, uid_field: :username, fields: [ :username, :password ]
end
