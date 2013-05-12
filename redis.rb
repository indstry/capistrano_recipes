namespace :redis do
  desc "Install the latest relase of Redis"
  task :install, roles: :app do
    # run "#{sudo} add-apt-repository ppa:chris-lea/redis-server"
    run "#{sudo} add-apt-repository ppa:chris-lea/redis-server",:pty => true do |ch, stream, data|
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
    run "#{sudo} apt-get -y install redis-server"
  end
  after "deploy:install", "redis:install"
end
