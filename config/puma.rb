# config/puma.rb

# Puma thread pool (min, max)
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

# How many workers (processes) to spin up
# In production use ENV['WEB_CONCURRENCY'], or default to 2
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))

# Preload the app before forking workers for lower memory & faster boots
preload_app!

# Always bind to the port provided by the environment
port ENV.fetch("PORT", 3000)

# Rack environment
environment ENV.fetch("RAILS_ENV", "development")

# Don't block on worker booting after fork
on_worker_boot do
  # Reconnect any threadsafe clients here, e.g. ActiveRecord
  if defined?(ActiveRecord)
    ActiveRecord::Base.establish_connection
  end
end

# Extend the default worker timeout (in seconds) to 1 hour
# Pick up from ENV or fallback
worker_timeout Integer(ENV.fetch("PUMA_WORKER_TIMEOUT", 3600))

# Allow puma to be restarted by `rails restart` command
plugin :tmp_restart
