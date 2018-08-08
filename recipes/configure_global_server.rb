#
# Cookbook Name::chef-prometheus
# Recipe::configure_global_server
#

server_groups = []

server_groups << find_server_group(:prometheus_server,
                                   "chef_environment:tools AND roles:#{node['prometheus']['server_role']}",
                                   9090)

if node['prometheus']['use_remote_storage']
  server_groups << find_server_group(:prometheus_database,
                                     "chef_environment:tools AND role:#{node['prometheus']['database']['server_role']} AND master:true",
                                     9201)
end

template "#{node['prometheus']['dir']}/prometheus.yml" do
  source 'configuration/server/prometheus.global.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    hostname: node['hostname'],
    server_groups: server_groups
  )
  notifies :restart, 'service[prometheus]', :delayed
end
