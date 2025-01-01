# Specify the source for gem installations  
source 'https://rubygems.org'  

# Define the Ruby version for the application  
ruby '3.2.2'  

# Specify the version of Rails to be used  
# Ensure compatibility with 7.1.3, with a minimum version of 7.1.3.4  
gem 'rails', '~> 7.1.3', '>= 7.1.3.4'  

# CORS middleware to handle Cross-Origin Resource Sharing  
gem 'rack-cors', require: 'rack/cors'  

# Sprockets integration for Rails asset pipeline  
gem 'sprockets-rails'  

# PostgreSQL as the database for Active Record  
gem 'pg', '~> 1.1'  

# Puma web server for handling HTTP requests  
gem 'puma', '>= 5.0'  

# JavaScript bundling with Rails  
gem 'jsbundling-rails'  

# Turbo for speeding up page loads and handling partial updates  
gem 'turbo-rails'  

# Stimulus for adding modest interactivity with JavaScript  
gem 'stimulus-rails'  

# CSS bundling for processing stylesheets in Rails  
gem 'cssbundling-rails'  

# Redis for caching and background job processing  
gem 'redis', '>= 4.0.1'  

# Time zone data for platforms lacking zoneinfo files  
gem 'tzinfo-data', platforms: %i[windows jruby]  

# Bootsnap for reducing boot times through caching  
gem 'bootsnap', require: false  

# Debugging tools for development  
gem 'debug', platforms: %i[mri windows]  

# RSpec for testing in Ruby on Rails  
gem 'rspec-rails', '~> 6.0.0'  

# Gems for the development environment  
group :development do  
  # Web console for interactive debugging in browser  
  gem 'web-console'  

  # Spring application preloader for faster development speed  
  gem 'spring'  

  # Byebug for debugging Ruby code  
  gem 'byebug', '~> 11.1'  
end  

# Gems for both development and test environments  
group :development, :test do  
  # Debugging tools specifically for MRI Ruby and Windows  
  gem 'debug', platforms: %i[mri windows]  

  # RSpec for testing capabilities  
  gem 'rspec-rails', '~> 6.0.0'  
end  

# Static code analysis and formatting tool  
gem 'rubocop'  

# Authentication solution for Rails applications  
gem 'devise'  

# Letter opener web for viewing emails in development  
gem 'letter_opener_web'  

# Phonelib gem for handling phone numbers in a consistent format  
gem 'phonelib'