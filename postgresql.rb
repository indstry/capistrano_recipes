set_default(:postgresql_host, "localhost")
set_default(:postgresql_user) { "" }
set_default(:postgresql_password) { ""}
set_default(:postgresql_database) { "#{application}_production" }

namespace :postgresql do

  desc "Add PostgreSQL apt Sources"
  task :add_sources do
    run "#{sudo} rm -f /etc/apt/sources.list.d/postgresql.list"
    run "#{sudo} touch /etc/apt/sources.list.d/postgresql.list"
    run "#{sudo} chmod -R 777 /etc/apt/sources.list.d/postgresql.list"
    run "echo 'deb http://apt.postgresql.org/pub/repos/apt/ precise-pgdg main' > /etc/apt/sources.list.d/postgresql.list"
  end

  desc "Add PostgreSQL gpg key"
  task :add_gpg do
    run "#{sudo} wget --quiet -O - http://apt.postgresql.org/pub/repos/apt/ACCC4CF8.asc > postgres.key"
    run "#{sudo} apt-key add postgres.key"
    run "#{sudo} apt-get update -y"
  end

  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do

    if postgresql_host != 'localhost'
      run "#{sudo} apt-get -y install postgresql-client libpq-dev"
    else
      run "#{sudo} apt-get -y install postgresql libpq-dev"
    end

  end
  after "deploy:install", "postgresql:add_sources"
  after 'postgresql:add_sources', 'postgresql:add_gpg'
  after 'postgresql:add_gpg','postgresql:install'

  desc "Create a database for this application."
  task :create_database, :on_error => :continue, roles: :db, only: {primary: true} do
    run %{#{sudo} -u postgres psql -c "create user #{postgresql_user} with password '#{postgresql_password}';"}
    run %{#{sudo} -u postgres psql -c "create database #{postgresql_database} owner #{postgresql_user};"}
  end
  after "deploy:setup", "postgresql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "postgresql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "postgresql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "postgresql:symlink"
end

