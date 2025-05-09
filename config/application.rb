require_relative "boot"  

require "rails"  
# Pick the frameworks you want:  
require "active_model/railtie"  
require "active_job/railtie"  
require "active_record/railtie"  
require "active_storage/engine"  
require "action_controller/railtie"  
require "action_mailer/railtie"  
require "action_mailbox/engine"  
require "action_text/engine"  
require "action_view/railtie"  
require "action_cable/engine"  
require 'axlsx'
require 'jwt'

# require "rails/test_unit/railtie"  

# Require the gems listed in Gemfile, including any gems  
# you've limited to :test, :development, or :production.  
Bundler.require(*Rails.groups)  

module SupplierApi  
  class Application < Rails::Application  
    # Initialize configuration defaults for originally generated Rails version.  
    config.load_defaults 7.1  
    
    config.autoload_paths << Rails.root.join('lib')
    # Configuration for the application, engines, and railties goes here.  
    #  
    # These settings can be overridden in specific environments using the files  
    # in config/environments, which are processed later.  
    #  
    # Uncomment and set the time zone if needed:  
    # config.time_zone = "Central Time (US & Canada)"  
    config.eager_load_paths << Rails.root.join("lib")  

    # Only loads a smaller set of middleware suitable for API only apps.  
    # Middleware like session, flash, cookies can be added back manually.  
    # Skip views, helpers and assets when generating a new resource.  
    #config.api_only = true  
    config.generators.system_tests = nil

    config.generators do |g|
      g.skip_routes true
      g.helper false
      g.assets false
      g.test_framework :rspec, fixture: false
      g.helper_specs false
      g.controller_specs false
      g.system_tests false
      g.view_specs false
    end

    # GZip all responses
    config.middleware.use Rack::Deflater

    config.to_prepare do
      Devise::SessionsController.layout "auth"
      # DeviseInvitable::RegistrationsController.layout "auth"
      # Devise::InvitationsController.layout "auth"
      Devise::RegistrationsController.layout "auth"
      Devise::ConfirmationsController.layout "auth"
      Devise::UnlocksController.layout "auth"
      Devise::PasswordsController.layout "auth"
      Devise::Mailer.layout "mailer"
    end
  end  
end