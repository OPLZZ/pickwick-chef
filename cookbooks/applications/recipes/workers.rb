
# Install ruby for workes
#
include_recipe "applications::ruby"

# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }
Chef::Recipe.send(:include, Opscode::OpenSSL::Password)

# Get api ip from Chef
#
if (api_node = (search(:node, "role:api")).first rescue nil)
  url   = api_node.applications[:api][:url].split(" ").first rescue nil
  token = api_node.applications[:api][:consumer_token]       rescue nil

  node.set[:applications][:workers][:api][:url]   = url   if url
  node.set[:applications][:workers][:api][:token] = token if token
end

# Get redis ip from Chef
#
if (sidekiq_redis = (search(:node, "role:sidekiq-redis")).first rescue nil)
  ip = sidekiq_redis.cloud.private_ips.first rescue nil
  node.set[:applications][:workers][:sidekiq][:ip] = ip if ip
end

node.set_unless[:applications][:workers][:sidekiq][:username] = "sidekiq"
node.set_unless[:applications][:workers][:sidekiq][:password] = secure_password

# Store current revision as "previous_revision"
#
ruby_block "save previous revision" do
  block { node.set[:applications][:workers][:previous_revision] = current_revision_sha(:workers) }
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
git "workers" do
  repository    node.applications[:workers][:repository]
  revision      node.applications[:workers][:revision]
  destination   "#{node.applications[:dir]}/#{node.applications[:workers][:name]}"
  user          node.applications[:user]
  group         node.applications[:user]
  action        :sync
end

# Save current revision to node
#
ruby_block "save current revision" do
  block { node.set[:applications][:workers][:current_revision] = current_revision_sha(:workers) }
end

# Create directories for puma
#
node.applications[:workers][:puma][:directories].values.each do |path|

  directory path do
    owner node.applications[:user] and group node.applications[:user] and mode 0755
    action :create
    recursive true
  end

end

rbenv_execute "workers bundle install" do
  command "bundle install --deployment --binstubs --without=development,test"
  cwd     "#{node.applications[:dir]}/#{node.applications[:workers][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  only_if do
    changed?('Gemfile', 'Gemfile.lock', application: :workers) ||
    ! File.exists?("#{node.applications[:workers][:dir]}/#{node.applications[:workers][:name]}/vendor/bundle")
  end
end

bash "restart sidekiq" do
  code "monit restart #{node.applications[:workers][:name]}-sidekiq"

  only_if "monit monitor #{node.applications[:workers][:name]}-sidekiq"
  only_if { node.applications[:workers][:current_revision] != node.applications[:workers][:previous_revision] }
end

bash "restart sidekiq web" do
  code "monit restart #{node.applications[:workers][:name]}-puma"

  only_if "monit monitor #{node.applications[:workers][:name]}-puma"
  only_if { node.applications[:workers][:current_revision] != node.applications[:workers][:previous_revision] }
end

# Create default nginx config
#
template "#{node.nginx[:dir]}/conf.d/default.conf" do
  source "default_nginx.conf.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

# Create nginx config
#
template "#{node.nginx[:dir]}/conf.d/#{node.applications[:workers][:name]}.conf" do
  source "pickwick-workers.nginx.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

monitrc "pickwick-workers" do
  template_cookbook "applications"
end
