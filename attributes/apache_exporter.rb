# Directory where the Apache Exporter binary will be installed
default['prometheus']['apache_exporter']['dir'] = '/opt/prometheus/apache_exporter'

# Location of Apache Exporter binary
default['prometheus']['apache_exporter']['binary'] = "#{node['prometheus']['apache_exporter']['dir']}/apache_exporter"

# Location of Apache Exporter pid file
default['prometheus']['apache_exporter']['pid'] = '/var/run/apache_exporter.pid'

# Location for Apache Exporter logs
default['prometheus']['apache_exporter']['log_dir'] = '/var/log/apache_exporter'

# Apache Exporter version to build
default['prometheus']['apache_exporter']['version'] = '0.5.0'

# Location for Apache Exporter pre-compiled binary.
default['prometheus']['apache_exporter']['binary_url']['i686'] = "https://github.com/Lusitaniae/apache_exporter/releases/download/v#{node['prometheus']['apache_exporter']['version']}/apache_exporter-#{node['prometheus']['apache_exporter']['version']}.linux-386.tar.gz"
default['prometheus']['apache_exporter']['binary_url']['x86_64'] = "https://github.com/Lusitaniae/apache_exporter/releases/download/v#{node['prometheus']['apache_exporter']['version']}/apache_exporter-#{node['prometheus']['apache_exporter']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
default['prometheus']['apache_exporter']['checksum']['i686'] = '466d3b883417c68e8dde93a12195603ab3c2869451ffc7811dac4ea73019543a'
default['prometheus']['apache_exporter']['checksum']['x86_64'] = '60dc120e0c5d9325beaec4289d719e3b05179531f470f87d610dc2870c118144'

default['prometheus']['apache_exporter']['server_role'] = 'prometheus_apache_exporter'
