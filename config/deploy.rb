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

require 'bundler/capistrano'
require 'rvm/capistrano'

set :rvm_ruby_string, '2.0.0-p598'

set :application, "remindem"
set :repository,  "https://github.com/instedd/remindem.git"
set :scm, :git
set :deploy_via, :remote_cache
set :user, 'ubuntu'
default_environment['TERM'] = ENV['TERM']

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end

  task :symlink_configs, :roles => :app do
    %W(database nuntium guisso hub).each do |file|
      run "ln -nfs #{shared_path}/#{file}.yml #{release_path}/config/"
    end
  end
end

namespace :foreman do
  desc 'Export the Procfile to Ubuntu upstart scripts'
  task :export, :roles => :app do
    env = {"PATH" => "$PATH", "GEM_HOME" => "$GEM_HOME", "GEM_PATH" => "$GEM_PATH", "RAILS_ENV" => "production"}
    concurrency = "worker=1"
    procfile = "Procfile"
    run "echo -e \"#{env.map{|k,v| "#{k}=#{v}"}.join("\\n")}\" >  #{current_path}/.env"
    run "cd #{current_path} && rvmsudo bundle exec foreman export upstart /etc/init -l #{shared_path}/log -f #{current_path}/#{procfile} -a #{application} -u #{user} --concurrency=\"#{concurrency}\""
  end

  desc "Start the application services"
  task :start, :roles => :app do
    sudo "start #{application}"
  end

  desc "Stop the application services"
  task :stop, :roles => :app do
    sudo "stop #{application}"
  end

  desc "Restart the application services"
  task :restart, :roles => :app do
    run "sudo start #{application} || sudo restart #{application}"
  end
end

before "deploy:start", "deploy:migrate"
before "deploy:restart", "deploy:migrate"
before "deploy:assets:precompile", "deploy:symlink_configs"

after "deploy:update", "foreman:export"
after "deploy:restart", "foreman:restart"
