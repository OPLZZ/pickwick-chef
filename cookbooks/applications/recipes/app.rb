# Install ruby for application
#
include_recipe "applications::ruby"

["sqlite3", "libsqlite3-dev", "libcurl4-openssl-dev"].each do |pkg|
  package pkg
end

# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }

# Store current revision as "previous_revision"
#
ruby_block "save previous revision" do
  block { node.set[:applications][:app][:previous_revision] = current_revision_sha(:app) }
end

bash "disable strict host checking for Github" do
  user node.applications[:user]
  code <<-EOS
    echo -e "host github.com\n\tUser git\n\tPort 22\n\t\n\tStrictHostKeyChecking no\n" >> #{node.applications[:dir]}/.ssh/config
  EOS
  not_if { File.read("#{node.applications[:dir]}/.ssh/config").include?("github.com") rescue nil }
end

# Clone the repository
#
git "app" do
  repository    node.applications[:app][:repository]
  revision      node.applications[:app][:revision]
  destination   "#{node.applications[:dir]}/#{node.applications[:app][:name]}"
  user          node.applications[:user]
  group         node.applications[:user]
  action        :sync
end

# Save current revision to node
#
ruby_block "save current revision" do
  block { node.set[:applications][:app][:current_revision] = current_revision_sha(:app) }
end

# Create directories for puma
#
node.applications[:app][:puma][:directories].values.each do |path|

  directory path do
    owner node.applications[:user] and group node.applications[:user] and mode 0755
    action :create
    recursive true
  end

end

rbenv_execute "app bundle install" do
  command "bundle install --deployment --binstubs --without=development test"
  cwd     "#{node.applications[:dir]}/#{node.applications[:app][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  only_if do
    changed?('Gemfile', 'Gemfile.lock', application: :app) ||
    ! File.exists?("#{node.applications[:app][:dir]}/#{node.applications[:app][:name]}/vendor/bundle")
  end
end

rbenv_execute "run migrations" do
  command "bundle exec rake db:migrate RAILS_ENV=#{node.applications[:app][:environment]}"

  cwd     "#{node.applications[:dir]}/#{node.applications[:app][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]
end

# Create puma config
#
template "#{node.applications[:dir]}/#{node.applications[:app][:name]}/config/puma.rb" do
  source "pickwick-app.puma.erb"
  owner node.applications[:user] and group node.applications[:user] and mode 0755
end

monitrc "pickwick-app" do
  template_cookbook "applications"
end

bash "restart application" do
  code "monit restart #{node.applications[:app][:name]}-puma"
  only_if { node.applications[:app][:current_revision] != node.applications[:app][:previous_revision] }
end

# Create nginx config
#
template "#{node.nginx[:dir]}/conf.d/#{node.applications[:app][:name]}.conf" do
  source "pickwick-app.nginx.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end
