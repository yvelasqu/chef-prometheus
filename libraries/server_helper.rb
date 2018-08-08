#
# Cookbook Name::prometheus2-latam
# Library::server_helper
#

def find_server(query, port, datacenter = nil)
  nodes = search(:node, query, filter_result: { 'backendipaddress' => ['backendipaddress'], 'hostname' => ['hostname'] }) # ~FC003
  nodes.select! { |host| datacenter == get_site(host) } if datacenter
  nodes.map { |node| Server.new(node['hostname'], node['backendipaddress'], port) }
end

def find_server_group(type, query, port, datacenter = nil)
  servers = find_server(query, port, datacenter)
  ServerGroup.new(type, servers)
end
