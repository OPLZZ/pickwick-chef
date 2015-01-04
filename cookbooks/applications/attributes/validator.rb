default.applications[:validator][:name]           = 'job-posting-validator'
default.applications[:validator][:repository]     = 'https://github.com/OPLZZ/job-posting-validator.git'
default.applications[:validator][:revision]       = 'master'
default.applications[:validator][:url]            = 'job-posting-validator.dev.vhyza.eu'
default.applications[:validator][:port]           = 80
default.applications[:validator][:environment]    = 'production'

default.applications[:validator][:fuseki][:version] = "1.0.2"

default.applications[:validator][:puma][:threads][:min]         = 1
default.applications[:validator][:puma][:threads][:max]         = 3
default.applications[:validator][:puma][:directories][:sockets] = "/var/run/puma/sockets"
default.applications[:validator][:puma][:directories][:pids]    = "/var/run/puma/pids"
default.applications[:validator][:puma][:wait]                  = 120
