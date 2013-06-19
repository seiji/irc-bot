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
set :normalize_asset_timestamps, false

set :host, 'data'
role :web,  host
role :app,  host
role :db,   host, :primary => true

set :bot_name, "seijit" if !

namespace :deploy do
  task :start, :roles => :app do
    svc('-u', bot_name)
  end

  task :stop, :roles => :app do
    svc('-d', bot_name)
  end

  task :restart, :roles => :app do
    svc('-h', bot_name)
  end

  task :setup_config, roles: :app do
    sudo "ln -fs #{current_path}/service/#{application}-#{bot_name} /service/#{application}-#{bot_name}"
  end
  after "deploy:setup", "deploy:setup_config"
end

# daemontools
set :svscan_root, "/service"
set :supervise_name, "#{application}"

def svc(cmd, name)
  sudo "svc #{cmd} #{svscan_root}/#{supervise_name}-#{name}"
end
