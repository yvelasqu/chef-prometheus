#
# Cookbook Name::chef-prometheus
# Recipe::configure_postgresql_adapter
#

directory node['prometheus']['database']['adapter']['log_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

logrotate_app 'database' do
  path "#{node['prometheus']['database']['adapter']['log_dir']}/postgresql_adapter.log"
  frequency 'daily'
  rotate 1
end

adapter_installed = "test -f #{node['prometheus']['database']['adapter']['binary']}"

cookbook_file node['prometheus']['database']['adapter']['binary'].to_s do
  source 'binaries/prometheus-postgresql-adapter/prometheus-postgresql-adapter'
  user 'root'
  group 'root'
  mode '0755'
  action :create
  not_if adapter_installed
end

template '/etc/init.d/postgresql_adapter' do
  source 'service/postgresql_adapter.erb'
  owner 'root'
  group 'root'
  mode '0755'
  variables(
    password: node['prometheus']['database']['password']
  )
  notifies :restart, 'service[postgresql_adapter]', :delayed
end

service 'postgresql_adapter' do
  supports status: true, restart: true, reload: false
  action :start
end
