require "bundler/capistrano"
# require 'sidekiq/capistrano'

# Comment recipes you don't use
load 'config/recipes/assets'
load "config/recipes/base"
load "config/recipes/nginx"
load "config/recipes/unicorn"
load "config/recipes/postgresql"
# load "config/recipes/mysql"
load "config/recipes/redis"
load "config/recipes/yamldb.rb"
load "config/recipes/nodejs"
load "config/recipes/imagemagick"
load "config/recipes/rbenv"
load "config/recipes/check"

server "server_addr", :web, :app, :db, primary: true

set :user, "deployer"
set :application, "app_name"
set :gitrepo, "gitrepo"
set :deploy_to, "/home/#{user}/apps/#{application}"
set :deploy_via, :remote_cache
set :use_sudo, false

# nginx Config
set :appserver,"unicorn"
set :nginxpath,"/etc/nginx/"
set :nginx_domain, 'domain.name'
set :nginx_normilizedomain, false
set :nginx_redirectdomains, ''

# PostgreSQL Config
set :postgresql_host, "localhost"
set :postgresql_user, "psql_username"
set :postgresql_password, ""
set :postgresql_database, "#{application}_production"

set :scm, "git"
#set :repository, "git@bitbucket.org:indstry/#{gitrepo}.git"
set :repository, "git@bitbucket.org:indstry/#{gitrepo}.git"
set :branch, "master"

default_run_options[:pty] = true
ssh_options[:forward_agent] = true
# default_run_options[:shell] = '/bin/zsh'

after "deploy", "deploy:migrate"
after "deploy", "deploy:cleanup"
after "deploy", "deploy:restart"