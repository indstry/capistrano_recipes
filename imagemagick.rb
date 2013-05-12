namespace :imagemagick do
  desc "Install  imagemagick"
  task :install, roles: :app do
    run "#{sudo} apt-get -y update"
    run "#{sudo} apt-get -y install libmagickwand-dev imagemagick libmagickcore-dev"
  end
  after "deploy:install", "imagemagick:install"
end
