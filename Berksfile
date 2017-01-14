source 'https://supermarket.chef.io'

# Install cookbooks with:
#
#     $ berks install --path ./site-cookbooks/
#
# Pre-requisites:
#
# * [gecode](http://www.gecode.org)  : $ brew install gecode
# * `berkshelf` gem                  : $ gem install berkshelf

# Base
#------------------------------------------------------------------------------
cookbook 'build-essential', '1.4.0'
cookbook 'yum',             '2.4.4'
cookbook 'apt',             '2.3.4'
cookbook 'curl',            '1.1.0'
cookbook 'vim',             '1.0.2'
cookbook 'git',             '2.5.2'
cookbook 'monit',           '0.7.1'
cookbook 'rbenv',           '1.6.5'
cookbook 'openssl',         '1.1.0'
cookbook 'ufw',             '0.7.4'
cookbook 'firewall',        '1.0.2'
cookbook 'ohai',            '1.1.12'
cookbook 'aws',             '0.101.6'
cookbook 'dmg',             '2.0.4'
cookbook 'chef_handler',    '1.1.4'
cookbook 'runit',           '1.3.0'
cookbook 'ark',             '0.5.0'


# Webserver
#------------------------------------------------------------------------------
cookbook 'nginx', '1.7.0'

# Database
#------------------------------------------------------------------------------
cookbook 'redisio', '1.7.1'

# Search
#------------------------------------------------------------------------------
cookbook 'java', '1.17.2'
cookbook 'elasticsearch', git: 'https://github.com/elasticsearch/cookbook-elasticsearch', ref: '0bd966d1aa27ab281b216676672b98e205d28d1e'
