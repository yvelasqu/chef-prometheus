#
# Cookbook Name::chef-prometheus
# Recipe::server
#
class Chef::Recipe
  include Site
  include Network
end

include_recipe 'ulimit'

user_ulimit 'root' do
  filehandle_limit 4096
end

directory node['prometheus']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['prometheus']['log_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

logrotate_app 'prometheus' do
  path "#{node['prometheus']['log_dir']}/prometheus.log"
  frequency 'daily'
  rotate 1
end

%w(curl tar bzip2).each do |pkg|
  package pkg do
    action :install
  end
end

prometheus_installed = "#{node['prometheus']['binary']} --version 2>&1 | grep prometheus | grep -F #{node['prometheus']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}.tar.gz" do
  source node['prometheus']['binary_url']
  checksum node['prometheus']['checksum']
  action :create
  not_if prometheus_installed
  notifies :run, 'execute[install_prometheus]', :immediately
end

execute 'install_prometheus' do
  user 'root'
  group 'root'
  command "tar -xzf #{Chef::Config[:file_cache_path]}/prometheus-#{node['prometheus']['version']}.tar.gz -C #{node['prometheus']['dir']} --strip-components=1"
  action :nothing
  notifies :restart, 'service[prometheus]', :delayed
end

# If Prometheus is global then search all prometheus servers and listen them.
# Otherwise, listen all exporters in the same datacenter.
if node['prometheus']['is_global']
  include_recipe 'chef-prometheus::configure_global_server'
else
  include_recipe 'chef-prometheus::configure_local_server'
end

template '/etc/init.d/prometheus' do
  source 'service/prometheus.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[prometheus]', :delayed
end

service 'prometheus' do
  supports status: true, restart: true, reload: false
  action :start
end
