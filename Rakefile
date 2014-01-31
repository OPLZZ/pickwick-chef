require 'json'

task :default => 'chef:sync'

namespace :chef do
  desc "Synchronize all resources (cookbooks, roles, etc.)"
  task :sync do
    sh  "bundle exec knife cookbook upload --all --yes"
    sh  "bundle exec knife role from file roles/*.rb"
  end
end

end
