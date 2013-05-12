set_default(:mongodb_host, "localhost:27017")
set_default(:mongodb_user) { "" }
set_default(:mongodb_password) { ""}
set_default(:mongodb_database) { "#{application}_production" }

namespace :mongodb do
  desc "Install the latest stable release of MongoDB."
  task :install, roles: :db, only: {primary: true} do
    run "#{sudo} apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10"
    run "#{sudo} echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' > /etc/apt/sources.list.d/10gen.list"
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install mongodb-10gen"
  end
  after "deploy:install", "mongodb:install"


  desc "Generate the mongodb.yml configuration file."
  task :setup, roles: :app do
    run "mkdir -p #{shared_path}/config"
    template "mongoid.yml.erb", "#{shared_path}/config/mongoid.yml"
  end
  after "deploy:setup", "mongodb:setup"

  desc "Symlink the mongoid.yml file into latest release"
  task :symlink, roles: :app do
    run "ln -nfs #{shared_path}/config/mongoid.yml #{release_path}/config/mongoid.yml"
  end
  after "deploy:finalize_update", "mongodb:symlink"
end
