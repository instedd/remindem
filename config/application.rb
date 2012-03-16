#encoding: utf-8

require File.expand_path('../boot', __FILE__)

require 'rails/all'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(:default, Rails.env) if defined?(Bundler)

module RememberMe
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)

    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # JavaScript files you want as :defaults (application.js is always included).
    config.action_view.javascript_expansions[:defaults] = %w(jquery rails)

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password]

    config.action_mailer_default_from = "Remindem <noreply@instedd.org>"

    config.suscribe_url = 'http://instedd.us2.list-manage.com/subscribe/post?u=b1404e482b02edd641e6506cf&id=6e0ca202fc'
    config.source_code_url = 'https://bitbucket.org/instedd/remindem/overview'
    config.backlog_url = 'https://bitbucket.org/instedd/remindem/issues?status=new&status=open'
    config.user_group_url = 'https://groups.google.com/group/instedd-tech'

    config.google_analytics = 'UA-XXXXXXX-XX'

    config.version_name = '1.6.1'

    # Languages
    config.available_locales = {
      :en => "English",
      :es => "Español"
    }

    # Default language
    config.default_locale = :en

    # Gettext configuration
    FastGettext.add_text_domain 'app', :path => 'config/locales', :type => :po, :ignore_fuzzy => true, :ignore_obsolte => true
    FastGettext.default_available_locales = config.available_locales.keys.map(&:to_s)
    FastGettext.default_text_domain = 'app'
    FastGettext.default_locale = 'en'
  end
end
