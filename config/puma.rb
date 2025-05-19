# config/puma.rb

# Puma thread pool (min, max)
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

# Only spin up clustered workers on non-Windows platforms
unless Gem.win_platform?
  workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
  preload_app!
end

# Always bind to the port provided by the environment
port        ENV.fetch("PORT",        3000)

# Rack environment
environment ENV.fetch("RAILS_ENV", "development")

# If you do end up forking (i.e. on non-Windows), reconnect ActiveRecord here
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Extend the default worker timeout (in seconds) to 1 hour
worker_timeout Integer(ENV.fetch("PUMA_WORKER_TIMEOUT", 3600))

# Allow puma to be restarted by `rails restart` command
plugin :tmp_restart
