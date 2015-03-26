#encoding: utf-8

# Copyright (C) 2011-2012, InSTEDD
#
# This file is part of Remindem.
#
# Remindem is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Remindem is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Remindem.  If not, see <http://www.gnu.org/licenses/>.

require File.expand_path('../boot', __FILE__)

require 'rails/all'

require "openid"
require 'openid/extensions/sreg'
require 'openid/extensions/pape'
require 'openid/store/filesystem'

# If you have a Gemfile, require the gems listed there, including any gems
# you've limited to :test, :development, or :production.
if defined?(Bundler)
  # If you precompile assets before deploying to production, use this line
  Bundler.require *Rails.groups(:assets => %w(development test))
  # If you want your assets lazily compiled in production, use this line
  # Bundler.require(:default, :assets, Rails.env)
end


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

    config.version_name = '1.7.0'

    # Enable asset pipeline
    config.assets.enabled = true
    config.assets.version = '1.0'

    # Languages
    config.available_locales = {
      :en => "English",
      :es => "Español"
    }

    # Default language
    config.default_locale = :en

    # Gettext configuration
    FastGettext.add_text_domain 'app', :path => 'config/locales', :type => :po, :ignore_fuzzy => true, :report_warning => false
    FastGettext.default_available_locales = config.available_locales.keys.map(&:to_s)
    FastGettext.default_text_domain = 'app'
    FastGettext.default_locale = 'en'
  end
end
