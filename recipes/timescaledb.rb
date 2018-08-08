#
# Cookbook Name::chef-prometheus
# Recipe::timescaledb
#
timescaledb_installed = "rpm -qa | grep -F 'timescaledb' | grep -F #{node['prometheus']['timescaledb']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/timescaledb-#{node['prometheus']['timescaledb']['version']}.rpm" do
  source node['prometheus']['timescaledb']['binary_url']
  checksum node['prometheus']['timescaledb']['checksum']
  action :create
  not_if timescaledb_installed
end

rpm_package 'timescaledb' do
  source "#{Chef::Config[:file_cache_path]}/timescaledb-#{node['prometheus']['timescaledb']['version']}.rpm"
  action :install
  not_if timescaledb_installed
  options '--force --nodeps'
end

yum_package 'timescaledb' do
  action :install
  not_if timescaledb_installed
  notifies :create, 'template[/var/lib/pgsql/10/data/postgresql.conf]', :immediately
end

template '/var/lib/pgsql/10/data/postgresql.conf' do
  source 'configuration/database/postgresql.conf.erb'
  user 'postgres'
  group 'postgres'
  mode '0600'
  action :create
  variables(
    timescaledb_installed: true
  )
  notifies :run, 'execute[restart_postgresql]', :delayed
end

execute 'create_timescale_extension' do
  user 'postgres'
  group 'postgres'
  command "psql -d prometheus -c 'CREATE EXTENSION timescaledb CASCADE;'"
  action :run
  not_if "psql -d prometheus -c '\\dx' | grep -F timescaledb"
end

execute 'restart_postgresql' do
  user 'root'
  group 'root'
  command 'systemctl restart postgresql-10'
  action :nothing
end
