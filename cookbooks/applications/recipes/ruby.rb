include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

node.applications[:rubies].each do |ruby|
  rbenv_ruby ruby['version'] do
    global true if ruby['global']
  end
end

node.applications[:rubies].each do |ruby|
  rbenv_gem "bundler" do
    ruby_version ruby['version']
  end
end

# Fix /opt/rbenv/libexec/rbenv-version-file-read: line 23: /dev/fd/62: No such file or directory issue
#
link "/dev/fd" do
  to "/proc/self/fd"
end
