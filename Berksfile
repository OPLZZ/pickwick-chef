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
cookbook 'redisio'

# Search
#------------------------------------------------------------------------------
cookbook 'java'
cookbook 'elasticsearch', git: 'https://github.com/elasticsearch/cookbook-elasticsearch'
