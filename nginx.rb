set_default(:appserver,"unicorn")
set_default(:nginxpath,"/etc/nginx/")
set_default(:nginx_normilizedomain,false)
set_default(:nginx_redirectdomains, "")

namespace :nginx do

  desc "Install latest stable release of nginx"
  task :install, roles: :web do
    if appserver != "passenger"
      # run "#{sudo} add-apt-repository ppa:nginx/stable"
      run "#{sudo} add-apt-repository ppa:nginx/stable",:pty => true do |ch, stream, data|
        if data =~ /Press.\[ENTER\].to.continue/
          #prompt, and then send the response to the remote process
          # ch.send_data(Capistrano::CLI.password_prompt("Press enter to continue:") + "\n")
          ch.send_data( "\n")
        else
          #use the default handler for all other text
          Capistrano::Configuration.default_io_proc.call(ch,stream,data)
        end
      end
      run "#{sudo} apt-get -y update"
      run "#{sudo} apt-get -y install nginx"
    else
      puts 'Using Passenger installed nginx'
    end
  end
  after "deploy:install", "nginx:install"

  desc "Setup nginx configuration for this application"
  task :setup, roles: :web do
    tmpconf = "/tmp/#{application}_nginx.conf"
    template "nginx_#{appserver}.erb", tmpconf
    run "mkdir -p #{shared_path}/log/nginx"
    run "#{sudo} mv #{tmpconf} #{File.join(nginxpath,'sites-enabled/',"#{application}_nginx.conf")}"
    run "#{sudo} rm -f #{File.join(nginxpath,'sites-enabled/default')}"
    restart
  end
  after "deploy:setup","nginx:setup"

  %w[start stop restart].each do |command|
    desc "#{command} nginx"
    task command, roles: :web do
      run "#{sudo} service nginx #{command}"
    end
  end


end
