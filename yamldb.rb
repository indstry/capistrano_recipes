namespace :db do
  desc "Download and load production database"
  task :pull do
    run "cd #{current_release} && RAILS_ENV=#{rails_env} bundle exec rake db:data:dump"
    download "#{current_release}/db/data.yml", "db/data.yml"
    `bundle exec rake db:reset db:data:load`
  end
end
