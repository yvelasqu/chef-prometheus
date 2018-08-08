#
# Cookbook Name::chef-prometheus
# Recipe::apache_exporter
#
directory node['prometheus']['apache_exporter']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

directory node['prometheus']['apache_exporter']['log_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

logrotate_app 'apache_exporter' do
  path "#{node['prometheus']['apache_exporter']['log_dir']}/apache_exporter.log"
  frequency 'daily'
  rotate 1
end

apache_exporter_installed = "#{node['prometheus']['apache_exporter']['binary']} --version 2>&1 | grep apache_exporter | grep -F #{node['prometheus']['apache_exporter']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/apache_exporter-#{node['prometheus']['apache_exporter']['version']}.tar.gz" do
  source node['prometheus']['apache_exporter']['binary_url'][node['kernel']['machine']]
  checksum node['prometheus']['apache_exporter']['checksum'][node['kernel']['machine']]
  action :create
  not_if apache_exporter_installed
  notifies :run, 'execute[install_apache_exporter]', :immediately
end

execute 'install_apache_exporter' do
  user 'root'
  group 'root'
  command "tar -xzf #{Chef::Config[:file_cache_path]}/apache_exporter-#{node['prometheus']['apache_exporter']['version']}.tar.gz -C #{node['prometheus']['apache_exporter']['dir']} --strip-components=1"
  action :nothing
  not_if apache_exporter_installed
  notifies :restart, 'service[apache_exporter]', :delayed
end

template '/etc/init.d/apache_exporter' do
  source 'service/apache_exporter.erb'
  owner 'root'
  group 'root'
  mode '0755'
  notifies :restart, 'service[apache_exporter]', :delayed
end

service 'apache_exporter' do
  supports status: true, restart: true, reload: false
  action :start
end
