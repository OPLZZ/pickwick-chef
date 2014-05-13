default.applications[:app][:name]           = 'pickwick-app'
default.applications[:app][:repository]     = 'https://github.com/OPLZZ/pickwick-app.git'
default.applications[:app][:revision]       = 'master'
default.applications[:app][:url]            = 'damepraci.cz'
default.applications[:app][:port]           = 80
default.applications[:app][:environment]    = 'production'

default.applications[:app][:puma][:threads][:min]         = 1
default.applications[:app][:puma][:threads][:max]         = 6
default.applications[:app][:puma][:directories][:sockets] = "/var/run/puma/sockets"
default.applications[:app][:puma][:directories][:pids]    = "/var/run/puma/pids"
default.applications[:app][:puma][:wait]                  = 120


# api and admin variables are currently overridden by role
#
default.applications[:app][:api][:url]   = nil
default.applications[:app][:api][:token] = nil

default.applications[:app][:admin][:username] = nil
default.applications[:app][:admin][:password] = nil
