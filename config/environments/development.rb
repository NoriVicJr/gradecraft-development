Rails.application.configure do
  config.action_controller.perform_caching = false
  config.action_dispatch.best_standards_support = :builtin
  config.asset_host = ENV["GC_ASSET_HOST"] || "//"

  config.action_mailer.default_url_options = { :host => "localhost:5000" }
  config.action_mailer.delivery_method = :sendmail
  config.action_mailer.perform_deliveries = true

  config.action_mailer.raise_delivery_errors = true
  config.action_view.raise_on_missing_translations = true
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.assets.compress = false
  config.assets.debug = true
  config.assets.quiet = true
  config.cache_classes = false
  config.cache_store = :memory_store
  config.consider_all_requests_local = true
  config.eager_load = false
  # config.file_watcher = ActiveSupport::EventedFileUpdateChecker
  config.log_level = :debug
  config.session_store :cookie_store, key: "_gradecraft_session"
end

CarrierWave.configure do |config|
  config.storage = :fog
  config.ignore_integrity_errors = false
  config.ignore_processing_errors = false
  config.ignore_download_errors = false
end
