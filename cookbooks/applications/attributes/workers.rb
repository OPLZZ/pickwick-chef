default.applications[:workers][:name]         = 'pickwick-workers'
default.applications[:workers][:repository]   = 'https://github.com/OPLZZ/pickwick-workers.git'
default.applications[:workers][:revision]     = 'master'
default.applications[:workers][:url]          = 'pickwick-workers.dev.vhyza.eu'
default.applications[:workers][:port]         = 80
default.applications[:workers][:environment]  = 'production'


default.applications[:workers][:puma][:threads][:min]         = 1
default.applications[:workers][:puma][:threads][:max]         = 6
default.applications[:workers][:puma][:directories][:sockets] = "/var/run/puma/sockets"
default.applications[:workers][:puma][:directories][:pids]    = "/var/run/puma/pids"
default.applications[:workers][:puma][:wait]                  = 120
