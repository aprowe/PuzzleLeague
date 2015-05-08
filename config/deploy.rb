# config valid only for current version of Capistrano
lock '3.4.0'

set :application, 'puzzle_league'
set :repo_url, 'git@github.com:aprowe/PuzzleLeague.git'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# set :branch, 'maast'

# Default deploy_to directory is /var/www/my_app_name
set :deploy_to, '/home/ubuntu/puzzle_league'

# Default value for :scm is :git
# set :scm, :git

# Default value for :format is :pretty
# set :format, :pretty

# Default value for :log_level is :debug
# set :log_level, :debug

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')

# Default value for linked_dirs is []
set :linked_dirs, fetch(:linked_dirs, []).push('node_modules')

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

role :app, 'ubuntu@rowealex.com'
role :db, 'ubuntu@rowealex.com'
role :web, 'ubuntu@rowealex.com'

# Default value for keep_releases is 5
set :keep_releases, 2

namespace :deploy do

  after :restart, :clear_cache do
    on roles(:web), in: :groups, limit: 3, wait: 10 do
      # Here we can do anything such as:
      within release_path do
        execute :npm, 'install', '--production'
      end
    end
  end

end
