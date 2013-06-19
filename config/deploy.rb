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

# daemontools
set :svscan_root, "/service"
set :supervise_name, "#{application}-#{bot_name}"
set :svname, "#{svscan_root}/.#{supervise_name}" 
set :acct_name, "logadmin"
set :acct_group, "logadmin"

def svc(cmd)
  sudo "svc #{cmd} #{svname}"
end

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
    sudo "mkdir    #{svname}"
    sudo "chmod +t #{svname}"
    sudo "mkdir    #{svname}/log"
    sudo "mkdir    #{svname}/log/main"
    sudo "touch    #{svname}/log/status"
    sudo "chown #{acct_name}:#{acct_group} #{svname}/log/main"
    sudo "chown #{acct_name}:#{acct_group} #{svname}/log/status"

    run_script = <<-EOS
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
export PATH

exec 2>&1
sleep 3

EOS
    sudo "cat #{run_script} >#{svname}/run"
    sudo "chmod +x #{svname}/run"

    run_log_script = <<-EOS
#!/bin/sh
exec setuidgid ${acct_name} multilog t s1000000 n100 ./main

EOS
    sudo "cat #{run_log_script} >#{svname}/log/run"
    sudo "chmod +x #{svname}/log/run"
    
#    sudo "ln -fs #{current_path}/service/#{application}-#{bot_name} /service/#{application}-#{bot_name}"
  end
  after "deploy:setup", "deploy:setup_config"
end

