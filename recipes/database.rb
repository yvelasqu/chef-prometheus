#
# Cookbook Name::chef-prometheus
# Recipe::database
#

directory node['prometheus']['database']['dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
end

postgresql_installed = "#{node['prometheus']['database']['binary']} --version 2>&1 | grep postgres | grep -F #{node['prometheus']['database']['version']}"

remote_file "#{Chef::Config[:file_cache_path]}/postgresql-#{node['prometheus']['database']['version']}.rpm" do
  source node['prometheus']['database']['binary_url']
  checksum node['prometheus']['database']['checksum']
  action :create
  not_if postgresql_installed
end

rpm_package 'postgresql10-server' do
  source "#{Chef::Config[:file_cache_path]}/postgresql-#{node['prometheus']['database']['version']}.rpm"
  action :install
  not_if postgresql_installed
end

yum_package 'postgresql10-server' do
  action :install
  not_if postgresql_installed
  notifies :run, 'execute[setup_postgresql]', :immediately
end

execute 'setup_postgresql' do
  user 'root'
  group 'root'
  command '/usr/pgsql-10/bin/postgresql-10-setup initdb'
  action :nothing
  notifies :start, 'service[postgresql-10]', :immediately
  notifies :run, 'execute[create_prometheus_user]', :immediately
end

execute 'create_prometheus_user' do
  user 'postgres'
  group 'postgres'
  command "(cat - << _EOF
#{node['prometheus']['database']['password']}
#{node['prometheus']['database']['password']}
_EOF
) | createuser -s -P --replication --login prometheus"
  action :nothing
end

template '/var/lib/pgsql/10/data/pg_hba.conf' do
  source 'configuration/database/pg_hba.conf.erb'
  user 'postgres'
  group 'postgres'
  mode '0600'
  action :create
  notifies :restart, 'service[postgresql-10]', :immediately
end

template '/var/lib/pgsql/10/data/postgresql.conf' do
  source 'configuration/database/postgresql.conf.erb'
  user 'postgres'
  group 'postgres'
  mode '0600'
  action :create
  not_if { node['prometheus']['database']['master'] }
  notifies :restart, 'service[postgresql-10]', :immediately
end

# Database prometheus to be replicate
execute 'create_database_prometheus' do
  user 'postgres'
  group 'postgres'
  command "psql -d postgres -c 'CREATE DATABASE prometheus'"
  action :run
  not_if "psql -c '\\l' postgres | grep prometheus"
end

# Include Prometheus extension to PostgreSQL
include_recipe 'chef-prometheus::configure_postgresql_extension'

if node['prometheus']['database']['master']
  # Include TimescaleDB
  include_recipe 'chef-prometheus::timescaledb'

  # Include PostgreSQL adapter to Prometheus
  include_recipe 'chef-prometheus::configure_postgresql_adapter'
end

service 'postgresql-10' do
  supports status: true, restart: true, reload: false
  action :start
end
