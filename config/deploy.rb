# Require the necessary Capistrano recipes
require 'rvm/capistrano'
require 'bundler/capistrano'
require 'sidekiq/capistrano'

# Repository settings, forked to an outside copy
set :repository, 'git@github.com:stefanobernardi/discourse.git'
set :deploy_via, :remote_cache
set :branch, fetch(:branch, 'master')
set :scm, :git
ssh_options[:forward_agent] = true

# General Settings
set :deploy_type, :deploy
default_run_options[:pty] = true

# Server Settings
set :user, 'discourse'
set :use_sudo, false
set :rails_env, :production
set :rbenv_ruby_version, '2.0.0-p353'

role :app, 'startupscene.it', primary: true
role :db,  'startupscene.it', primary: true
role :web, 'startupscene.it', primary: true

# Application Settings
set :application, 'discourse'
set :deploy_to, "/home/#{user}/#{application}"

namespace :deploy do
  # Tasks to start, stop and restart thin. This takes Discourse's
  # recommendation of changing the RUBY_GC_MALLOC_LIMIT.
  desc 'Start thin servers'
  task :start, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml start", :pty => false
  end

  desc 'Stop thin servers'
  task :stop, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && bundle exec thin -C config/thin.yml stop"
  end

  desc 'Restart thin servers'
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "cd #{current_path} && RUBY_GC_MALLOC_LIMIT=90000000 bundle exec thin -C config/thin.yml restart"
  end

  # Sets up several shared directories for configuration and thin's sockets,
  # as well as uploading your sensitive configuration files to the serer.
  # The uploaded files are ones I've removed from version control since my
  # project is public. This task also symlinks the nginx configuration so, if
  # you change that, re-run this task.
  task :setup_config, roles: :app do
    run  "mkdir -p #{shared_path}/config/initializers"
    run  "mkdir -p #{shared_path}/config/environments"
    run  "mkdir -p #{shared_path}/sockets"
    put  File.read("config/discourse.conf"), "#{shared_path}/config/discourse.conf"
    put  File.read("config/nginx.conf"), "#{shared_path}/config/nginx.conf"
    put  File.read("config/database.yml"), "#{shared_path}/config/database.yml"
    put  File.read("config/redis.yml"), "#{shared_path}/config/redis.yml"
    put  File.read("config/twitter.yml"), "#{shared_path}/config/twitter.yml"
    put  File.read("config/environments/production.rb"), "#{shared_path}/config/environments/production.rb"
    put  File.read("config/initializers/secret_token.rb"), "#{shared_path}/config/initializers/secret_token.rb"
    sudo "cp #{shared_path}/config/nginx.conf /etc/nginx/sites-enabled/#{application}"
    sudo "cp #{shared_path}/config/nginx.conf /etc/nginx/conf.d/discourse.conf"
    sudo "/etc/init.d/nginx reload"
    puts "Configs uploaded and NginX reloaded."
  end

  # Symlinks all of your uploaded configuration files to where they should be.
  task :symlink_config, roles: :app do
    run  "ln -nfs #{shared_path}/config/discourse.conf #{release_path}/config/discourse.conf"
    run  "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run  "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
    run  "ln -nfs #{shared_path}/config/redis.yml #{release_path}/config/redis.yml"
    run  "ln -nfs #{shared_path}/config/twitter.yml #{release_path}/config/twitter.yml"
    run  "ln -nfs #{shared_path}/config/environments/production.rb #{release_path}/config/environments/production.rb"
    run  "ln -nfs #{shared_path}/config/initializers/secret_token.rb #{release_path}/config/initializers/secret_token.rb"
  end
end

after "deploy:setup", "deploy:setup_config"
after "deploy:finalize_update", "deploy:symlink_config"

namespace :db do
  desc 'Seed your database for the first time'
  task :seed do
    run "cd #{current_path} && psql -d discourse_production < pg_dumps/production-image.sql"
  end
end

after  'deploy:update_code', 'deploy:migrate'