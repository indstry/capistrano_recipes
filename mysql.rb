set_default(:mysql_host, "localhost")
set_default(:mysql_user) { "" }
set_default(:mysql_password) { ""}
set_default(:mysql_database) { "#{application}_production" }

namespace :mysql do
  desc "Install the latest stable release of PostgreSQL."
  task :install, roles: :db, only: {primary: true} do
    # run "#{sudo} add-apt-repository ppa:pitti/postgresql"
    run "#{sudo} apt-get -y update"
    #Select One option.

    # MySQL Client and libs only
    # run "#{sudo} apt-get -y install mysql-client libmysql-ruby libmysqlclient-dev"

    # full MySQL Server
    secret_password = Capistrano::CLI.ui.ask "Enter a root password for MySQL Server:"
    run "#{sudo} debconf-set-selections <<< 'mysql-server mysql-server/root_password password #{secret_password}'"
    run "#{sudo} debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password #{secret_password}'"
    run "#{sudo} apt-get -y install mysql-server mysql-client libmysql-ruby libmysqlclient-dev"

  end
  after "deploy:install", "mysql:install"

  desc "Create a database for this application."
  task :create_database, roles: :db, only: {primary: true} do
    run %Q{mysql -u root -p -e "CREATE USER #{mysql_user} IDENTIFIED BY PASSWORD '#{mysql_password}';"}
    run %Q{mysql -u root -p -e "create database #{mysql_database};"}
    run %Q{mysql -u root -p -e "GRANT ALL ON #{mysql_database}.* TO '#{mysql_user}'@'%';"}
    run %Q{mysql -u root -p -e "GRANT ALL ON #{mysql_database}.* TO '#{mysql_user}'@'localhost';"}
  end
  after "deploy:setup", "mysql:create_database"

  desc "Generate the database.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mysql.yml.erb", "#{shared_path}/config/database.yml"
  end
  after "deploy:setup", "mysql:setup"

  desc "Symlink the database.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end
  after "deploy:finalize_update", "mysql:symlink"
end
