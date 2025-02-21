require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Reloading is disabled in production
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false

  # Serve static files if RAILS_SERVE_STATIC_FILES is set
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Use local file storage for uploaded files (adjust if needed)
  config.active_storage.service = :local

  # Force all access over SSL
  config.force_ssl = true

  # Logging configuration: log to STDOUT with tags
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap { |logger| logger.formatter = ::Logger::Formatter.new }
    .then { |logger| ActiveSupport::TaggedLogging.new(logger) }
  config.log_tags = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # ACTION MAILER CONFIGURATION
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
  config.action_mailer.default_url_options = { host: ENV.fetch("HOST", "https://digitalconstruction.onrender.com") }

  # I18n fallbacks
  config.i18n.fallbacks = true

  # Do not dump schema after migrations.
  config.active_record.dump_schema_after_migration = false

  config.action_cable.allowed_request_origins = [
  "https://digitalconstruction.onrender.com",
  "http://localhost:3000"
]
end
