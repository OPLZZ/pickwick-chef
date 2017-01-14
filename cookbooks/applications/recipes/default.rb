# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }

ruby_block "save SSL certificate" do
  block do
    File.open("/etc/nginx/certificate.crt", "w") do |f|
      f.write node.applications[:certificate][:ssl_certificate]
    end

    File.open("/etc/nginx/certificate.key", "w") do |f|
      f.write node.applications[:certificate][:ssl_certificate_key]
    end
  end

  not_if  { File.exists?("/etc/nginx/certificate.crt") || File.exists?("/etc/nginx/certificate.key") }
  only_if { node.applications[:certificate][:ssl_certificate] && node.applications[:certificate][:ssl_certificate_key] }
end


# Create user directory
#
directory node.applications[:dir] do
  owner node.applications[:user] and group node.applications[:user] and mode 0775
  recursive true
end

# Create user and group
#
user node.applications[:user] do
  comment  "Applications User"
  shell    "/bin/bash"
  home     node.applications[:dir]
  supports :manage_home => true
  action   :create
end

group node.applications[:user] do
  members [ node.applications[:user]]
  action :create
end

directory node.applications[:dir] do
  owner node.applications[:user] and group node.applications[:user] and mode 0775
  recursive true
end

include_recipe "elasticsearch::nginx"

directory "#{node.applications[:dir]}/.ssh" do
  owner node.applications[:user] and group node.applications[:user] and mode 0700
  recursive true
end
