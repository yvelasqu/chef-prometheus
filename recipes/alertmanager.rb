#
# Cookbook Name::chef-prometheus
# Recipe::alertmanager
#
directory node['prometheus']['alertmanager']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['prometheus']['alertmanager']['data_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['prometheus']['alertmanager']['log_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

logrotate_app 'alertmanager' do
  path "#{node['prometheus']['alertmanager']['log_dir']}/alertmanager.log"
  frequency 'daily'
  rotate 1
end

alertmanager_installed = "#{node['prometheus']['alertmanager']['binary']} --version 2>&1 | grep alertmanager | grep -F #{node['prometheus']['alertmanager']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/alertmanager-#{node['prometheus']['alertmanager']['version']}.tar.gz" do
  source node['prometheus']['alertmanager']['binary_url']
  checksum node['prometheus']['alertmanager']['checksum']
  action :create
  not_if alertmanager_installed
  notifies :run, 'execute[install_alertmanager]', :immediately
end

execute 'install_alertmanager' do
  user 'root'
  group 'root'
  command "tar -xzf #{Chef::Config[:file_cache_path]}/alertmanager-#{node['prometheus']['alertmanager']['version']}.tar.gz -C #{node['prometheus']['alertmanager']['dir']} --strip-components=1"
  action :nothing
  not_if alertmanager_installed
  notifies :restart, 'service[alertmanager]', :delayed
end

template node['prometheus']['alertmanager']['config_file'] do
  source 'configuration/alertmanager.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    slack_webhook: node['prometheus']['alertmanager']['slack_webhook']
  )
  notifies :restart, 'service[alertmanager]', :delayed
end

template '/etc/init.d/alertmanager' do
  source 'service/alertmanager.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[alertmanager]', :delayed
end

service 'alertmanager' do
  supports status: true, restart: true, reload: false
  action :start
end
