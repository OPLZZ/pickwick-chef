# Infrastructure Chef cookbooks
---

[Chef](http://www.getchef.com/chef/) cookbooks for project [damepraci.cz](http://www.damepraci.cz).

## Provided cookbooks

#### monitoring

Simple cookbook for service monitoring using [Monit](http://mmonit.com/monit/).

Provides recipes for elasticsearch, nginx and redis monitoring.

#### applications

Cookbook for provisioning applications which are necessary for [damepraci.cz](http://www.damepraci.cz) project.

Recipes:

* [default](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/default.rb) &mdash; recipe for application user and directories preparation
* [ruby](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/ruby.rb) &mdash; recipe for [Ruby](https://www.ruby-lang.org/en/) installation and configuration
* [hunspell](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/hunspell.rb) &mdash; recipe for elasticsearch's [hunspell](http://www.elasticsearch.org/guide/en/elasticsearch/reference/current/analysis-hunspell-tokenfilter.html) analyzer dictionary
* [api](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/api.rb) &mdash; recipe for provisioning [pickwick-api](https://github.com/OPLZZ/pickwick-api)
* [app](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/app.rb) &mdash; recipe for provisioning frontend application [pickwick-app](https://github.com/OPLZZ/pickwick-app)
* [validator](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/validator.rb) &mdash; recipe for provisioning [job-posting-validator](https://github.com/OPLZZ/job-posting-validator)
* [workers](https://github.com/OPLZZ/pickwick-chef/blob/master/cookbooks/applications/recipes/workers.rb) &mdash; recipe for provisioning [pickwick-workers](https://github.com/OPLZZ/pickwick-workers)

## Provided roles

Whole infrastructure is divided into several roles.

* [api](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/api.rb) &mdash; role for application API. This role installs and configures [elasticsearch](http://elasticsearch.org) which is main storage in this project. Installs [Ruby](http://ruby-lang.org) and [pickwick-api](https://github.com/OPLZZ/pickwick-api) repository.
* [app](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/api.rb) &mdash; role for frontend applications. This role installs and configures [Ruby](http://ruby-lang.org) and [pickwick-app](https://github.com/OPLZZ/pickwick-app) repository.
* [elasticsearch](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/elasticsearch.rb) &mdash; role for [elasticsearch](http://elasticsearch.org) installation and configuration. This role is not used separately in the infrustructure. It is used in api role.
* [sidekiq-redis](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/sidekiq-redis.rb) &mdash; role for [redis](http://redis.io) installation and configuration. This role is not used separately in the infrustructure. It is used in workers role.
* [validator](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/validator.rb) &mdash; role for [job-posting-validator](https://github.com/OPLZZ/job-posting-validator) installation and configuration.
* [workers](https://github.com/OPLZZ/pickwick-chef/blob/master/roles/workers.rb) &mdash; role for [pickwick-workers](https://github.com/OPLZZ/pickwick-workers) installation and configuration.

## Installation

### Prerequisites

First, you need to have a valid Chef Server account, your user validation key, and your organization validation key.

The easiest way is to create a free account in [Hosted Chef](http://www.opscode.com/hosted-chef/), provided by Opscode.

You need to export the following environment variables for the provisioning scripts:

    export CHEF_ORGANIZATION='<your organization name>'
    export CHEF_ORGANIZATION_KEY='/path/to/your/your-organization-validator.pem'
    export NGINX_USER='<nginx username>'
    export NGINX_PASSWORD='<nginx user password>'
    export MONIT_USER='<monit username>'
    export MONIT_PASSWORD='<monit user password>'

### Proxmox Virtual Environment

To build the stack in _Proxmox Virtual Environment_ you need to specify, in addition to previous environment variables, following variables:

    export PVE_NODE_NAME='<your node name>'
    export PVE_CLUSTER_URL='<your node cluster url>'
    export PVE_USER_NAME='<your node user name>'
    export PVE_USER_PASSWORD='<your node user password>'
    export PVE_USER_REALM='<your node user realm, for example pve>'

For test deploy in Proxmox Virtual Environment server run something like:
    export PROVIDER=PVE

    git clone https://github.com/OPLZZ/pickwick-chef.git
    cd pickwick-chef

... install the required rubygems:

    bundle install

... install the site cookbooks with [Berkshelf](http://berkshelf.com):

    berks install --path ./site-cookbooks/

... upload the cookbooks and roles to Chef Server:

    bundle exec rake chef:sync

... build API server

    bundle exec knife proxmox server create --hostname pickwick-api \
                                            --cpus 2 \
                                            --mem 2048 \
                                            --swap 0 \
                                            --disk 20 \
                                            --template TEMPLATE_ID \
                                            --ipaddress IP \
                                            --run-list "role[api]" \
                                            --distro debian

... build workers server

    bundle exec knife proxmox server create --hostname pickwick-workers \
                                            --cpus 2 \
                                            --mem 2048 \
                                            --swap 0 \
                                            --disk 20 \
                                            --template TEMPLATE_ID \
                                            --ipaddress IP \
                                            --run-list "role[workers]" \
                                            --distro debian

... build frontend server

    bundle exec knife proxmox server create --hostname pickwick-app \
                                            --cpus 2 \
                                            --mem 512 \
                                            --swap 0 \
                                            --disk 20 \
                                            --template TEMPLATE_ID \
                                            --ipaddress IP \
                                            --run-list "role[app]" \
                                            --distro debian

... build validator server

    bundle exec knife proxmox server create --hostname pickwick-validator \
                                            --cpus 2 \
                                            --mem 2048 \
                                            --swap 0 \
                                            --disk 20 \
                                            --template TEMPLATE_ID \
                                            --ipaddress IP \
                                            --run-list "role[validator]" \
                                            --distro debian

... or you can create server with all parts of the infrastructure

    bundle exec knife proxmox server create --hostname pickwick \
                                            --cpus 4 \
                                            --mem 8192 \
                                            --swap 0 \
                                            --disk 20 \
                                            --template TEMPLATE_ID \
                                            --ipaddress IP \
                                            --run-list "role[api],role[workers],role[validator],role[app]" \
                                            --distro debian

Please note that this deployment option is for _development purposes only_ and it _will be deleted in the near future_.

### Amazon EC2

Please note that deployment is not fully tested yet.

To build the stack in Amazon EC2, in addition to previouse credentials, you need to export the path to your private SSH key, downloaded from the AWS console:

    export SSH_IDENTITY_FILE='/path/to/your/name-ec2.pem'

and set provider to Amazon by following environment variable

    export PROVIDER=AMAZON

You also need to create the following security groups:

* elasticsearch with ports 9200 and 9300 opened to the api and elasticsearch groups, 2812 opened to the outside world
* api with ports 80 and 2812 opened to the outside world
* workers with port 2812 opened to the outside world
* frontend with ports 80 and 2812 opened to the outside world
* validator with ports 80 and 2812 opened to the outside world

After that you can clone this repository, install required rubygems, install cookbooks, upload cookbooks to the Chef Server and create server(s).

git clone https://github.com/OPLZZ/pickwick-chef.git
    cd pickwick-chef

... install the required rubygems:

    bundle install

... install the site cookbooks with [Berkshelf](http://berkshelf.com):

    berks install --path ./site-cookbooks/

... upload the cookbooks and roles to Chef Server:

    bundle exec rake chef:sync

... build API server

    bundle exec knife ec2 server create --node-name pickwick-api \
                                        --tags Role=api \
                                        --ssh-user ec2-user \
                                        --groups api \
                                        --image ami-8fb7b2fb
                                        --flavor m1.medium
                                        --region eu-west-1
                                        --availability-zone eu-west-1a \
                                        --distro amazon \
                                        --run-list 'role[api]'

... build workers server

    bundle exec knife ec2 server create --node-name pickwick-workers \
                                        --tags Role=workers \
                                        --ssh-user ec2-user \
                                        --groups workers \
                                        --image ami-8fb7b2fb
                                        --flavor m1.small
                                        --region eu-west-1
                                        --availability-zone eu-west-1a \
                                        --distro amazon \
                                        --run-list 'role[workers]'

... build frontend server

    bundle exec knife ec2 server create --node-name pickwick-app \
                                        --tags Role=app \
                                        --ssh-user ec2-user \
                                        --groups frontend \
                                        --image ami-8fb7b2fb
                                        --flavor m1.small
                                        --region eu-west-1
                                        --availability-zone eu-west-1a \
                                        --distro amazon \
                                        --run-list 'role[app]'

... build validator server

    bundle exec knife ec2 server create --node-name pickwick-validator \
                                        --tags Role=validator \
                                        --ssh-user ec2-user \
                                        --groups validator \
                                        --image ami-8fb7b2fb
                                        --flavor m1.small
                                        --region eu-west-1
                                        --availability-zone eu-west-1a \
                                        --distro amazon \
                                        --run-list 'role[validator]'

... or you can create server with all parts of the infrastructure

    bundle exec knife ec2 server create --node-name pickwick \
                                        --tags Role=app \
                                        --ssh-user ec2-user \
                                        --groups api,workers,validator,app \
                                        --image ami-8fb7b2fb
                                        --flavor m3.large
                                        --region eu-west-1
                                        --availability-zone eu-west-1a \
                                        --distro amazon \
                                        --run-list 'role[api],role[workers],role[validator],role[app]'

----
