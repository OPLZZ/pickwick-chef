# Configuration file for Chef's `knife` command
# =============================================
#
# The configuration expects you to have following pre-requisites:
#
# * Your Chef user present in ~/.chef/USERNAME.pem
#
# * The `CHEF_ORGANIZATION` environment variable containing the Chef organization exported
#
# * The `CHEF_ORGANIZATION_KEY` environment variable containing full path to organization
#   [validation key](https://manage.opscode.com/organizations) exported
#
# * For starting instances in Amazon AWS, the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`
#   environment variables exported
#
# You can export environment variables eg. in your `~/.bashrc` or `~/.profile` files:
#
#     export CHEF_ORGANIZATION='my-organization'
#     export CHEF_ORGANIZATION_KEY='/path/to/my-organization-validator.pem'
#
# Make sure to reload the file when you change it:
#
#     source ~/.bashrc
#     source ~/.profile
#

def check_environment_variable(name, message=nil)
  unless ENV[name]
    puts "[!] You have to export the #{name} environment variable", (message || '')
    exit!(1)
  end
end

check_environment_variable 'HOME'
check_environment_variable 'USER'
check_environment_variable 'CHEF_ORGANIZATION'
check_environment_variable 'CHEF_ORGANIZATION_KEY'
check_environment_variable 'NGINX_USER'
check_environment_variable 'NGINX_PASSWORD'
check_environment_variable 'MONIT_USER'
check_environment_variable 'MONIT_PASSWORD'
check_environment_variable 'PROVIDER', 'You need to specify desired PROVIDER. Available options are AMAZON | PVE (just for testing)'

current_dir = File.dirname(__FILE__)

log_level                :info
log_location             STDOUT

node_name                ENV['USER']
client_key               "#{ENV['HOME']}/.chef/#{ENV['USER']}.pem"
validation_client_name   "#{ENV['CHEF_ORGANIZATION']}-validator"
validation_key           ENV['CHEF_ORGANIZATION_KEY']
chef_server_url          "https://api.opscode.com/organizations/#{ENV['CHEF_ORGANIZATION']}"
cache_options            :path => "#{current_dir}/.chef/tmp/checksums"

cookbook_path            ["#{current_dir}/site-cookbooks", "#{current_dir}/cookbooks"]

case ENV['PROVIDER'].to_s
when 'AMAZON'
  check_environment_variable 'AWS_ACCESS_KEY_ID'
  check_environment_variable 'AWS_SECRET_ACCESS_KEY'
  check_environment_variable 'SSH_IDENTITY_FILE'

  knife[:aws_access_key_id]     = ENV['AWS_ACCESS_KEY_ID']
  knife[:aws_secret_access_key] = ENV['AWS_SECRET_ACCESS_KEY']
  knife[:aws_ssh_key_id]        = "#{ENV['CHEF_ORGANIZATION']}-aws"
  knife[:region]                = ENV['AWS_REGION'] || 'us-east-1'
  knife[:image]                 = 'ami-9d23aeea' # (Amazon Linux 2014.09)
  knife[:ssh_user]              = 'ec2-user'
  knife[:ssh_attribute]         = 'ec2.public_hostname'
  knife[:use_sudo]              = true
  knife[:ssh_identity_file]     = ENV['SSH_IDENTITY_FILE']
  knife[:no_host_key_verify]    = true

# NOTE: Just for testing, this option will be removed in future
#
when 'PVE'
  check_environment_variable 'PVE_NODE_NAME'
  check_environment_variable 'PVE_CLUSTER_URL'
  check_environment_variable 'PVE_USER_NAME'
  check_environment_variable 'PVE_USER_PASSWORD'
  check_environment_variable 'PVE_USER_REALM'

  knife[:ssh_user]              = ENV['USER']
  knife[:use_sudo]              = true
  knife[:ssh_identity_file]     = "#{ENV['HOME']}/.ssh/#{ENV['USER']}-virtual"
  knife[:no_host_key_verify]    = true

  knife[:pve_node_name]         = ENV['PVE_NODE_NAME']
  knife[:pve_cluster_url]       = ENV['PVE_CLUSTER_URL']
  knife[:pve_user_name]         = ENV['PVE_USER_NAME']
  knife[:pve_user_password]     = ENV['PVE_USER_PASSWORD']
  knife[:pve_user_realm]        = ENV['PVE_USER_REALM']
end

knife[:bootstrap_version]     = '11.6.2'
