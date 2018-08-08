# Directory where the Node Exporter binary will be installed
default['prometheus']['node_exporter']['dir'] = '/opt/prometheus/node_exporter'

# Location of Node Exporter binary
default['prometheus']['node_exporter']['binary'] = "#{node['prometheus']['node_exporter']['dir']}/node_exporter"

# Location of Node Exporter pid file
default['prometheus']['node_exporter']['pid'] = '/var/run/node_exporter.pid'

# Location for Node Exporter logs
default['prometheus']['node_exporter']['log_dir'] = '/var/log/node_exporter'

# Node Exporter version to build
default['prometheus']['node_exporter']['version'] = '0.15.2'

# Location for Node Exporter pre-compiled binary.
default['prometheus']['node_exporter']['binary_url'] = "https://github.com/prometheus/node_exporter/releases/download/v#{node['prometheus']['node_exporter']['version']}/node_exporter-#{node['prometheus']['node_exporter']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
default['prometheus']['node_exporter']['checksum'] = '1ce667467e442d1f7fbfa7de29a8ffc3a7a0c84d24d7c695cc88b29e0752df37'

default['prometheus']['node_exporter']['server_role'] = 'prometheus_node_exporter'
