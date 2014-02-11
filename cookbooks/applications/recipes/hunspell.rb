remote_directory "#{node.elasticsearch[:path][:conf]}/hunspell" do
  source "hunspell"
  files_owner node.elasticsearch[:user]
  files_group node.elasticsearch[:user]
  owner       node.elasticsearch[:user]
  group       node.elasticsearch[:user]
  mode 00755

  notifies :restart, 'service[elasticsearch]' unless node.elasticsearch[:skip_restart]
end
