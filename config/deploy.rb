require "bundler/capistrano"
require 'capistrano_colors'

set :application, "irc-bot"

# scm
set :repository,  "git@github.com:seiji/irc-bot.git"
set :scm, :git
set :git_shallow_clone, 1
set :git_enable_submodules, 1
set :branch, "master"

set :user, "deploy"
set :group, user
set :runner, user
set :use_sudo,false
set(:run_method) { use_sudo ? :sudo : :run }

# strategy
set :deploy_via, :remote_cache
set :deploy_to, "/srv/#{application}"
set :current_path, "#{deploy_to}/current"
set :shared_path, "#{deploy_to}/shared"

set :host, 'data'
role :web,  host
role :app,  host
role :db,   host, :primary => true

namespace :deploy do
  task :start, :roles => :app do
    svc('-u')
  end

  task :stop, :roles => :app do
    svc('-d')
  end

  task :restart, :roles => :app do
    svc('-h')
  end

  task :setup_config, roles: :app do
    %w(seijit).each do |name|
      sudo "ln -fs #{current_path}/service/#{application}-#{name} /service/#{application}-#{name}"
    end
  end
  after "deploy:setup", "deploy:setup_config"
end

# daemontools
set :svscan_root, "/service"
set :supervise_name, "#{application}"

def svc(cmd)
  sudo "svc #{cmd} #{svscan_root}/#{supervise_name}"
end
