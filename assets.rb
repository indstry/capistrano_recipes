def remote_file_exists?(full_path)
  'true' ==  capture("if [ -e #{full_path} ]; then echo 'true'; fi").strip
end

namespace :assets do
  desc "Precompile Assets locally and upload via scp"
  task :precompile, :roles => :web do
    # Check if assets have changed. If not, don't run the precompile task - it takes a long time.
    # force_compile = false
    # changed_asset_count = 0
    # begin
    #   from = source.next_revision(current_revision)
    #   asset_locations = 'app/assets\|lib/assets\|vendor/assets'
    #   changed_asset_count = capture("cd #{latest_release} && git whatchanged -1 --format=oneline | grep '#{asset_locations}' | wc -l").to_i
    # rescue Exception => e
    #   logger.info "Error: #{e}, forcing precompile"
    #   force_compile = true
    # end
    # if !remote_file_exists?("#{shared_path}/assets_revision") then
    #   run "echo '0' > #{shared_path}/assets_revision"
    # end
    # 
    # if releases.length <= 1 || changed_asset_count > 0 || force_compile then
      # logger.info "#{changed_asset_count} assets have changed. Pre-compiling"
      run_locally("rake assets:clean && rake assets:precompile")
      run_locally "cd public && tar -jcf assets.tar.bz2 assets"
      top.upload "public/assets.tar.bz2", "#{shared_path}", :via => :scp
      run "cd #{shared_path} && tar -jxf assets.tar.bz2 && rm assets.tar.bz2"
      run_locally "rm public/assets.tar.bz2"
      run_locally("rake assets:clean")
      # run "echo -n #{source.next_revision(current_revision)} > #{shared_path}/assets_revision"
    # else
    #   logger.info "#{changed_asset_count} assets have changed. Skipping asset pre-compilation"
    # end
  end
  task :symlink, roles: :web do
    run ("rm -rf #{latest_release}/public/assets &&
          mkdir -p #{latest_release}/public &&
          mkdir -p #{shared_path}/assets &&
          ln -s #{shared_path}/assets #{latest_release}/public/assets")
  end
end
before 'deploy:finalize_update', 'assets:symlink'
after 'deploy', 'assets:precompile'