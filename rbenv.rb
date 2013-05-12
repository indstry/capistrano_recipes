set_default :ruby_version, "2.0.0-p0"
set_default :rbenv_bootstrap, "bootstrap-ubuntu-12-04"

namespace :rbenv do
  desc "Install rbenv, Ruby, and the Bundler gem"
  task :install, roles: :app,:on_error => :continue  do
    run "#{sudo} apt-get -y install curl git-core"
    run "curl -L https://raw.github.com/fesplugas/rbenv-installer/master/bin/rbenv-installer | bash"

    bashrc = <<-BASHRC
if [ -d $HOME/.rbenv ]; then
  export PATH="$HOME/.rbenv/bin:$PATH"
  eval "$(rbenv init -)"
fi
BASHRC
    put bashrc, "/tmp/rbenvrc"
    run "cat /tmp/rbenvrc ~/.bashrc > ~/.bashrc.tmp"
    run "mv ~/.bashrc.tmp ~/.bashrc"
    run %q{export PATH="$HOME/.rbenv/bin:$PATH"}
    run %q{eval "$(rbenv init -)"}
    run "#{sudo} apt-get -y install build-essential zlib1g-dev libssl-dev libreadline-gplv2-dev"
    run "rbenv install #{ruby_version}",:pty => true do |ch, stream, data|
      if data =~ /continue.with.installation\?.\(y\/N\)/
        #prompt, and then send the response to the remote process
        # ch.send_data(Capistrano::CLI.password_prompt("Press enter to continue:") + "\n")
        ch.send_data( "N\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end

    end

    run "rbenv global #{ruby_version}"
    run "gem install bundler --no-ri --no-rdoc",:pty => true do |ch, stream, data|
      if data =~ /Overwrite.the.executable\?.\[yN\]/
        #prompt, and then send the response to the remote process
        # ch.send_data(Capistrano::CLI.password_prompt("Press enter to continue:") + "\n")
        ch.send_data( "y\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end
    run "gem install rails --no-ri --no-rdoc",:pty => true do |ch, stream, data|
      if data =~ /Overwrite.the.executable\?.\[yN\]/
        ch.send_data( "y\n")
      else
        #use the default handler for all other text
        Capistrano::Configuration.default_io_proc.call(ch,stream,data)
      end
    end
    # run "gem install bundler --no-ri --no-rdoc"
    # run "gem install rails --no-ri --no-rdoc"
    run "rbenv rehash"
  end
  after "deploy:install", "rbenv:install"
end
