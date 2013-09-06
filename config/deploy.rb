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

set :host, 'linode2'
role :web,  host
role :app,  host
role :db,   host, :primary => true

set :bot_name, "seijit" unless exists? :bot_name

# daemontools
set :svscan_root, "/service"
set :supervise_name, "#{application}-#{bot_name}"
set :svname, "#{svscan_root}/#{supervise_name}" 
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

    run_script = <<-EOF
#!/bin/sh

PATH=/bin:/usr/bin:/sbin:/usr/sbin:/usr/local/bin
export PATH

exec 2>&1
exec setuidgid deploy bash -c '
  cd /srv/irc-bot/current;
  source /etc/profile;
  bundle exec ruby bots/#{bot_name}.rb
'

EOF
    put run_script, "/tmp/run"
    sudo "chown root:root /tmp/run"
    sudo "mv /tmp/run #{svname}/run"
    sudo "chmod +x #{svname}/run"

    run_log_script = <<-EOF
#!/bin/sh
exec setuidgid #{acct_name} multilog t s1000000 n100 ./main

EOF
    put run_log_script, "/tmp/run_log"
    sudo "chown root:root /tmp/run_log"
    sudo "mv /tmp/run_log #{svname}/log/run"
    sudo "chmod +x #{svname}/log/run"
  end
  after "deploy:setup", "deploy:setup_config"

end

