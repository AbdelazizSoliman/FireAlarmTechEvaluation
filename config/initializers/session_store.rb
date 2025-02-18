Rails.application.config.session_store :cookie_store,
  key: '_supplier_api_session',
  domain: 'digitalconstruction.onrender.com',
  same_site: :none,
  secure: Rails.env.production?
