# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }

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

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

node.applications[:rubies].each do |ruby|
  rbenv_ruby ruby['version'] do
    global true if ruby['global']
  end
end

node.applications[:rubies].each do |ruby|
  rbenv_gem "bundler" do
    ruby_version ruby['version']
  end
end

# Fix /opt/rbenv/libexec/rbenv-version-file-read: line 23: /dev/fd/62: No such file or directory issue
#
link "/dev/fd" do
  to "/proc/self/fd"
end

include_recipe "elasticsearch::nginx"

# Create default nginx config
#
template "#{node.nginx[:dir]}/conf.d/default.conf" do
  source "default_nginx.conf.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

directory "#{node.applications[:dir]}/.ssh" do
  owner node.applications[:user] and group node.applications[:user] and mode 0700
  recursive true
end
