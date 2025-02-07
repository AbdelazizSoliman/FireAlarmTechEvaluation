require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reload code on every request (development)
  config.enable_reloading = true
  config.eager_load = false

  # Full error reports
  config.consider_all_requests_local = true
  config.server_timing = true

  # Caching
  if Rails.root.join("tmp/caching-dev.txt").exist?
    config.action_controller.perform_caching = true
    config.action_controller.enable_fragment_cache_logging = true
    config.cache_store = :memory_store
    config.public_file_server.headers = { "Cache-Control" => "public, max-age=#{2.days.to_i}" }
  else
    config.action_controller.perform_caching = false
    config.cache_store = :null_store
  end

  # File storage
  config.active_storage.service = :local

  # Action Mailer configuration for SMTP
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              ENV['SMTP_ADDRESS'] || "smtp.gmail.com",
    port:                 ENV['SMTP_PORT'] || 587,
    domain:               ENV['SMTP_DOMAIN'] || "gmail.com",
    user_name:            ENV['SMTP_USERNAME'] || "abdelaziz.soliman89@gmail.com",
    password:             ENV['SMTP_PASSWORD'] || "smhldoxawubxmqiv",
    authentication:       "plain",
    enable_starttls_auto: true
  }
  config.action_mailer.default_url_options = { host: "localhost", port: 3000 }

  # Other development settings...
  config.active_support.deprecation = :log
  config.active_record.migration_error = :page_load
  config.active_record.verbose_query_logs = true
  config.active_job.verbose_enqueue_logs = true
  config.assets.quiet = true

  config.hosts << "localhost"

  # Uncomment if you wish to allow Action Cable access from any origin.
  # config.action_cable.disable_request_forgery_protection = true

  # Raise error when a before_action's only/except options reference missing actions
  config.action_controller.raise_on_missing_callback_actions = true
end
