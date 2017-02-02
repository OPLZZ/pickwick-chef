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
    export MONIT_ALERT_EMAIL='<email for alerts>'
    export MONIT_FROM_EMAIL='<email from>'
    export MONIT_SMTP_SERVER='<smtp server>'
    export MONIT_SMTP_PORT='<smtp port>'
    export MONIT_SMTP_USER='<smtp username>'
    export MONIT_SMTP_PASSWORD='<smtp password>'
    export PICKWICK_API_URL='<url of API>'
    export PICKWICK_API_TOKEN='<read only API token>'
    export PICKWICK_API_RW_TOKEN='<API token>'
    export PICKWICK_ADMIN_USERNAME='<admin username>'
    export PICKWICK_ADMIN_PASSWORD='<admin password>'
    export SIDEKIQ_USERNAME='<sidekiq username>'
    export SIDEKIQ_PASSWORD='<sidekiq password>'

### Installation

    git clone https://github.com/OPLZZ/pickwick-chef.git
    cd pickwick-chef

... install the required rubygems:

    bundle install

... install the site cookbooks with [Berkshelf](http://berkshelf.com):

    berks vendor ./site-cookbooks/

... upload the cookbooks and roles to Chef Server:

    bundle exec rake chef:sync

... build server

### DigitalOcean preparation

... create `~/.ssh/digitalocean-damepraci` using ssh-keygen

... set environment variable to public key

```
export SSH_PUBLIC_FILE=~/.ssh/digitalocean-damepraci.pub
export SSH_IDENTITY_FILE=~/.ssh/digitalocean-damepraci
```

... add ssh key to digitalocean account
```
bundle exec knife digital_ocean sshkey create --sshkey-name digitalocean-damepraci \
                                              --public-key $SSH_PUBLIC_FILE
```

... get ssh key id
```
export SSH_KEY_ID=$(bundle exec knife digital_ocean sshkey list | grep digitalocean-damepraci | cut -d' ' -f1)
```

... create droplet
```
bundle exec knife digital_ocean droplet create --server-name damepraci.cz \
                                               --image debian-7-x64 \
                                               --location fra1 \
                                               --size 2gb \
                                               --ssh-keys $SSH_KEY_ID \
                                               --bootstrap \
                                               --distro debian \
                                               --ssh-port 22 \
                                               --identity-file $SSH_IDENTITY_FILE
```
----

... create volume named `damepraci.cz` using DigitalOcean UI and attach it to the damepraci.cz droplet

... add desired role to the node
```
bundle exec knife node run_list add damepraci.cz "role[whole_stack]"
```

... run chef-client again
```
knife ssh "name:damepraci.cz" -a ipaddress -x root --identity-file $SSH_IDENTITY_FILE chef-client
```

## Funding
<a href="http://esfcr.cz/" target="_blank"><img src="https://www.damepraci.cz/assets/oplzz_banner_en.png" alt="Project of Operational Programme Human Resources and Employment No. CZ.1.04/5.1.01/77.00440."></a>
The project No. CZ.1.04/5.1.01/77.00440 was funded from the European Social Fund through the Operational Programme Human Resources and Employment and the state budget of Czech Republic.
