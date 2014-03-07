

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
    require 'uri'
    require 'net/http'
    #fix url for request
    main_repo_url = default.applications[:app][:repository].gsub(".git", "")

    #add to url latest releases
    latest_release_url = URI("#{main_repo_url}/releases/latest")

    #find latest tag name
    latest_tag = Net::HTTP.get_response(latest_release_url)['Location'].split("tag/").last

    #build url for latest release
    asset_url = URI("#{main_repo_url}/releases/download/#{latest_tag}/release.tar.gz")

    #ask for exact location of file
    asset_location_url = Net::HTTP.get_response(asset_url)['Location']

    #writing asset data to temp file
    tmp_file = "/tmp/release_#{latest_tag}.tar.gz"
    File.open(tmp_file, "wb") do |fw|
      fw.write(Net::HTTP.get(URI(asset_location_url)))
    end

    #unpacking file to main directory #{node.applications[:dir]}/#{node.applications[:app][:name]}/
    latest_release_dir = "#{node.applications[:dir]}/#{node.applications[:app][:name]}/release_#{latest_tag}"
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

