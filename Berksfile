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
cookbook 'build-essential'
cookbook 'yum', '2.4.4'
cookbook 'apt'
cookbook 'curl'
cookbook 'vim'
cookbook 'git'
cookbook 'monit'
cookbook 'rbenv'
cookbook 'openssl'

# Webserver
#------------------------------------------------------------------------------
cookbook 'nginx'

# Database
#------------------------------------------------------------------------------
cookbook 'redisio', '1.7.1'

# Search
#------------------------------------------------------------------------------
cookbook 'java'
cookbook 'elasticsearch', git: 'https://github.com/elasticsearch/cookbook-elasticsearch'
