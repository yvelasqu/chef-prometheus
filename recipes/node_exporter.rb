#
# Cookbook Name::chef-prometheus
# Recipe::node_exporter
#
directory node['prometheus']['node_exporter']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['prometheus']['node_exporter']['log_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

logrotate_app 'node_exporter' do
  path "#{node['prometheus']['node_exporter']['log_dir']}/node_exporter.log"
  frequency 'daily'
  rotate 1
end

package 'glibc-static' do
  action :install
end

node_exporter_installed = "#{node['prometheus']['node_exporter']['binary']} --version 2>&1 | grep node_exporter | grep -F #{node['prometheus']['node_exporter']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/node_exporter-#{node['prometheus']['node_exporter']['version']}.tar.gz" do
  source node['prometheus']['node_exporter']['binary_url']
  checksum node['prometheus']['node_exporter']['checksum']
  action :create
  not_if node_exporter_installed
  notifies :run, 'execute[install_node_exporter]', :immediately
end

execute 'install_node_exporter' do
  user 'root'
  group 'root'
  command "tar -xzf #{Chef::Config[:file_cache_path]}/node_exporter-#{node['prometheus']['node_exporter']['version']}.tar.gz -C #{node['prometheus']['node_exporter']['dir']} --strip-components=1"
  action :nothing
  not_if node_exporter_installed
  notifies :restart, 'service[node_exporter]', :delayed
end

template '/etc/init.d/node_exporter' do
  source 'service/node_exporter.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[node_exporter]', :delayed
end

service 'node_exporter' do
  supports status: true, restart: true, reload: false
  action :start
end
