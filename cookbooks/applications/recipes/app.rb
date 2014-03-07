

# Create App directory
#
directory "#{node.applications[:dir]}/#{node.applications[:app][:name]}" do
  owner node.applications[:user] and group node.applications[:user] and mode 0775
  recursive true
end

# Create App log directory
#
directory "#{node.applications[:dir]}/#{node.applications[:app][:name]}/log" do
  owner node.applications[:user] and group node.applications[:user] and mode 0775
  recursive true
end


ruby_block "Download and unpack APP from github latest release" do
  block do
    #fix url for request
    main_repo_url = node.applications[:app][:repository].gsub(".git", "")

    puts main_repo_url
    #add to url latest releases
    latest_release_url = "#{main_repo_url}/releases/latest"

    puts latest_release_url

    #find latest tag name
    request = `curl --head #{latest_release_url}`
    latest_tag = request.split("\n").find{|l| l.include?("Location")}.split("tag/").last.strip

    #build url for latest relse
    asset_url = "#{main_repo_url}/releases/download/#{latest_tag}/release.tar.gz"

    #get asset data to temp file
    tmp_file = "/tmp/release_#{latest_tag}.tar.gz"
    `curl -L -o #{tmp_file} #{asset_url}`

    #unpacking file to main directory #{node.applications[:dir]}/#{node.applications[:app][:name]}/
    latest_release_dir = "#{node.applications[:dir]}/#{node.applications[:app][:name]}/release_#{latest_tag}"
    `mkdir #{latest_release_dir}`

    `tar -xzf #{tmp_file} -C #{latest_release_dir}`

    #delete old symlink to previous latest version
    `rm #{node.applications[:dir]}/#{node.applications[:app][:name]}/public`

    #create new symlink to latest version
    `ln -s #{latest_release_dir}/www #{node.applications[:dir]}/#{node.applications[:app][:name]}/public`
  end
end


# Create PickwickApp nginx config
#
template "#{node.nginx[:dir]}/conf.d/#{node.applications[:app][:name]}.conf" do
  source "pickwick-app.nginx.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

