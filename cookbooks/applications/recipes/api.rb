# Load the GitChanged extension
#
[Chef::Recipe, Chef::Resource].each { |l| l.send :include, GitChanged }

# Get elasticsearch ip from Chef
#
if (elasticsearch_node = (search(:node, "role:elasticsearch")).first rescue nil)
  ip = elasticsearch_node.cloud.private_ips.first rescue nil
  node.set[:applications][:api][:elasticsearch][:ip] = ip if ip
end

# Get redis ip from Chef
#
if (sidekiq_redis = (search(:node, "role:sidekiq-redis")).first rescue nil)
  ip = sidekiq_redis.cloud.private_ips.first rescue nil
  node.set[:applications][:api][:sidekiq][:ip] = ip if ip
end

# Store current revision as "previous_revision"
#
ruby_block "save previous revision" do
  block { node.set[:applications][:api][:previous_revision] = current_revision_sha(:api) }
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
git "api" do
  repository    node.applications[:api][:repository]
  revision      node.applications[:api][:revision]
  destination   "#{node.applications[:dir]}/#{node.applications[:api][:name]}"
  user          node.applications[:user]
  group         node.applications[:user]
  action        :sync
end

# Save current revision to node
#
ruby_block "save current revision" do
  block { node.set[:applications][:api][:current_revision] = current_revision_sha(:api) }
end

# Create directories for puma
#
node.applications[:api][:puma][:directories].values.each do |path|

  directory path do
    owner node.applications[:user] and group node.applications[:user] and mode 0755
    action :create
    recursive true
  end

end

rbenv_execute "api bundle install" do
  command "bundle install --deployment --binstubs --without=development,test"
  cwd     "#{node.applications[:dir]}/#{node.applications[:api][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]

  only_if do
    changed?('Gemfile', 'Gemfile.lock', application: :api) ||
    ! File.exists?("#{node.applications[:api][:dir]}/#{node.applications[:api][:name]}/vendor/bundle")
  end
end

node.set_unless[:applications][:api][:consumer_token] = Digest::SHA1.hexdigest("#{Time.now.to_i}-#{rand(10000)}")

rbenv_execute "run api setup" do
  command "bundle exec rake setup CONSUMER_TOKEN=#{node.applications[:api][:consumer_token]}"

  cwd     "#{node.applications[:dir]}/#{node.applications[:api][:name]}"
  user    node.applications[:user]
  group   node.applications[:user]
end

# Create puma config
#
template "#{node.applications[:dir]}/#{node.applications[:api][:name]}/puma.rb" do
  source "pickwick-api.puma.erb"
  owner node.applications[:user] and group node.applications[:user] and mode 0755
end

bash "restart application" do
  code "monit restart #{node.applications[:api][:name]}-puma"
  only_if { node.applications[:api][:current_revision] != node.applications[:api][:previous_revision] }
end

# Create nginx config
#
template "#{node.nginx[:dir]}/conf.d/#{node.applications[:api][:name]}.conf" do
  source "pickwick-api.nginx.erb"
  owner node.nginx[:user] and group node.nginx[:user] and mode 0755
  notifies :reload, 'service[nginx]'
end

monitrc "pickwick-api" do
  template_cookbook "applications"
end
