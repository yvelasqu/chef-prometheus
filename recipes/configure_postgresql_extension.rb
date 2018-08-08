#
# Cookbook Name::chef-prometheus
# Recipe::configure_postgresql_extension
#

extension_installed = "PGPASSWORD=#{node['prometheus']['database']['password']} psql -U prometheus -h 127.0.0.1 -d prometheus -c '\\dx' | grep -F pg_prometheus"

remote_file "#{Chef::Config[:file_cache_path]}/pg_prometheus-#{node['prometheus']['database']['pg_prometheus']['version']}.tar.gz" do
  source node['prometheus']['database']['pg_prometheus']['binary_url']
  checksum node['prometheus']['database']['pg_prometheus']['checksum']
  action :create
  not_if extension_installed
end

yum_package %w(postgresql10-devel gcc) do
  action :install
  not_if extension_installed
  notifies :run, 'execute[uncompress_extension]', :immediately
end

execute 'uncompress_extension' do
  cwd Chef::Config[:file_cache_path]
  user 'root'
  group 'root'
  command "tar -xzf #{Chef::Config[:file_cache_path]}/pg_prometheus-#{node['prometheus']['database']['pg_prometheus']['version']}.tar.gz"
  action :nothing
  not_if extension_installed
  notifies :run, 'bash[make_extension]', :immediately
end

bash 'make_extension' do
  cwd "#{Chef::Config[:file_cache_path]}/pg_prometheus-#{node['prometheus']['database']['pg_prometheus']['version']}"
  user 'root'
  group 'root'
  code <<-EOH
    export PATH=$PATH:/usr/pgsql-10/bin
    make
    make install
    EOH
  action :nothing
  not_if extension_installed
  notifies :run, 'execute[install_extension]', :immediately
end

execute 'install_extension' do
  user 'postgres'
  group 'postgres'
  command "psql -d prometheus -c 'CREATE EXTENSION pg_prometheus;'"
  action :nothing
  not_if extension_installed
end
