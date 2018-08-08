#
# Cookbook Name::chef-prometheus
# Recipe::configure_local_server
#

alerts_config_files = %w(example.alerts.yml)
alerts_config_files.each do |alert|
  cookbook_file "#{node['prometheus']['dir']}/#{alert}" do
    source "configuration/alerts/#{alert}"
    owner 'root'
    group 'root'
    mode '0644'
    notifies :restart, 'service[prometheus]', :delayed
  end
end

server_groups = []
datacenter = node['prometheus'].fetch('server_dc', get_site)

server_groups << find_server_group(:apache_exporter,
                                   "(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:#{node['prometheus']['apache_exporter']['server_role']}",
                                   9113,
                                   datacenter)

server_groups << find_server_group(:node_exporter,
                                   "(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:#{node['prometheus']['node_exporter']['server_role']}",
                                   9100,
                                   datacenter)

server_groups << find_server_group(:cadvisor,
                                   '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND recipes:cadvisor',
                                   8080,
                                   datacenter)

template "#{node['prometheus']['dir']}/prometheus.yml" do
  source 'configuration/server/prometheus.local.yml.erb'
  owner 'root'
  group 'root'
  mode '0644'
  variables(
    datacenter: datacenter,
    hostname: node['hostname'],
    alerts_config_files: alerts_config_files,
    server_groups: server_groups
  )
  notifies :restart, 'service[prometheus]', :delayed
end
