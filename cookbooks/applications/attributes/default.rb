default.applications[:user]                 = 'applications'
default.applications[:dir]                  = '/var/www/applications'
default.applications[:rubies]               = [ { 'version' => '2.1.0', 'global' => true } ]
default.applications[:ruby_gc_malloc_limit] = 90000000
default.rbenv[:group_users]                 = [node.applications[:user]]
