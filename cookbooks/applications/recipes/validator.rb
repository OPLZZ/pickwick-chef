# Install ruby for validator
#
include_recipe "applications::ruby"

# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }

# Store current revision as "previous_revision"
#
ruby_block "save previous revision" do
  block { node.set[:applications][:validator][:previous_revision] = current_revision_sha(:validator) }
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
git "validator" do
  repository    node.applications[:validator][:repository]
  revision      node.applications[:validator][:revision]
  destination   "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user          node.applications[:user]
  group         node.applications[:user]
  action        :sync
end

# Save current revision to node
#
ruby_block "save current revision" do
  block { node.set[:applications][:validator][:current_revision] = current_revision_sha(:validator) }
end

# Create directories for puma
#
node.applications[:validator][:puma][:directories].values.each do |path|

  directory path do
    owner node.applications[:user] and group node.applications[:user] and mode 0755
    action :create
    recursive true
  end

end

rbenv_execute "validator bundle install" do
  command "bundle install --deployment --binstubs --without=development,test"
  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  only_if do
    changed?('Gemfile', 'Gemfile.lock', application: :validator) ||
    ! File.exists?("#{node.applications[:validator][:dir]}/#{node.applications[:validator][:name]}/vendor/bundle")
  end
end

rbenv_execute "install fuseki server" do
  command "bundle exec rake validator:fuseki:install FUSEKI_VERSION=#{node.applications[:validator][:fuseki][:version]}"

  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  not_if { File.exists?("#{node.applications[:dir]}/#{node.applications[:validator][:name]}/vendor/jena-fuseki-#{node.applications[:validator][:fuseki][:version]}/fuseki") }
end

rbenv_execute "stop fuseki server" do
  command "bundle exec rake validator:fuseki:stop"

  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]
end

rbenv_execute "import background data" do
  command "bundle exec rake validator:data:import_background_data"

  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  not_if { File.exists?("#{node.applications[:dir]}/#{node.applications[:validator][:name]}/vendor/jena-fuseki-#{node.applications[:validator][:fuseki][:version]}/fuseki") }
end

rbenv_execute "start fuseki server" do
  command "bundle exec rake validator:fuseki:init"

  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]
end

# Compile assets
#
rbenv_execute "compile assets" do
  command "bundle exec rake assets:precompile RAILS_ENV=production"

  cwd     "#{node.applications[:dir]}/#{node.applications[:validator][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]
end

# Create puma config
#
template "#{node.applications[:dir]}/#{node.applications[:validator][:name]}/puma.rb" do
  source "validator.puma.erb"
  owner node.applications[:user] and group node.applications[:user] and mode 0755
end

bash "restart application" do
  code "monit restart #{node.applications[:validator][:name]}-puma"
  only_if { node.applications[:validator][:current_revision] != node.applications[:validator][:previous_revision] }
end

# Create nginx config
#
template "#{node.nginx[:dir]}/conf.d/#{node.applications[:validator][:name]}.conf" do
  source "validator.nginx.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

monitrc "validator" do
  template_cookbook "applications"
end
