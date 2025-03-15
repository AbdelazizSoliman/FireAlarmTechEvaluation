# config/initializers/session_store.rb

if Rails.env.production?
  Rails.application.config.session_store :cookie_store,
    key: '_supplier_api_session',
    domain: 'digitalconstruction.onrender.com',  # only for production
    same_site: :none,
    secure: true
else
  Rails.application.config.session_store :cookie_store,
    key: '_supplier_api_session',
    same_site: :lax   # or :none, but typically :lax is fine in dev
end
