source 'http://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

gem 'rails', '3.2.21'
gem 'haml-rails'

gem 'mysql2'
gem 'devise', '~> 1.5.4'
gem 'delayed_job_active_record'
gem 'nuntium_api', '>=0.12'
gem 'hub_client', github: 'instedd/ruby-hub_client', branch: 'master'
gem 'instedd_telemetry', github: "instedd/telemetry_rails", branch: 'master'
gem 'jquery-rails', '~> 2.1.0'
gem 'client_side_validations'

gem "ice_cube", "~> 0.6.13"
gem "symbolize"
gem 'kaminari'
gem 'foreman'

gem "omniauth"
gem "omniauth-openid"
gem 'ruby-openid'
gem 'rack-oauth2'
gem 'alto_guisso', git: "https://github.com/instedd/alto_guisso.git", branch: 'master'
gem 'alto_guisso_rails', git: "https://github.com/instedd/alto_guisso_rails.git", branch: 'master'

gem 'breadcrumbs_on_rails'
gem 'fast_gettext'
gem 'gettext_i18n_rails'
gem 'io-console'

group :development, :test do
  gem "rand", "~> 0.9.1"
  gem 'test-unit'
  gem 'mocha', :require => false
  gem 'ffaker'
  gem 'machinist'
  gem 'ci_reporter'
  gem 'pry-byebug'
end

group :assets do
  gem 'sass-rails',   '~> 3.2.3'
  gem 'coffee-rails', '~> 3.2.1'
  gem 'uglifier',     '>= 1.0.3'
  gem 'execjs',       '~> 2.0.2'
end

group :development do
  gem 'ruby_parser'
  gem 'locale'
  gem 'hpricot'
end

group :development do
  gem 'capistrano',         '~> 3.6', :require => false
  gem 'capistrano-rails',   '~> 1.2', :require => false
  gem 'capistrano-bundler', '~> 1.2', :require => false
  gem 'rvm'
  gem 'licit'
end

group :webserver do
  gem 'puma', '~> 3.0.2'
end
