# Directory where the prometheus binary will be installed
default['prometheus']['dir'] = '/opt/prometheus'

# Location of Prometheus binary
default['prometheus']['binary'] = "#{node['prometheus']['dir']}/prometheus"

# Location of Prometheus pid file
default['prometheus']['pid'] = '/var/run/prometheus.pid'

# Location for Prometheus logs
default['prometheus']['log_dir'] = '/var/log/prometheus'

# Prometheus version to build
default['prometheus']['version'] = '2.2.1'

# Location for Prometheus pre-compiled binary.
default['prometheus']['binary_url'] = "https://github.com/prometheus/prometheus/releases/download/v#{node['prometheus']['version']}/prometheus-#{node['prometheus']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
default['prometheus']['checksum'] = 'ec1798dbda1636f49d709c3931078dc17eafef76c480b67751aa09828396cf31'

default['prometheus']['cli_opts']['config.file'] = "#{node['prometheus']['dir']}/prometheus.yml"

# Only log messages with the given severity or above. Valid levels: [debug, info, warn, error, fatal, panic].
default['prometheus']['cli_opts']['log.level'] = 'info'

# Base path for metrics storage.
default['prometheus']['cli_opts']['storage.tsdb.path'] = '/opt/prometheus/data'

# Retention policy.
default['prometheus']['cli_opts']['storage.tsdb.retention'] = '15d'

# Retention policy.
default['prometheus']['cli_opts']['storage.tsdb.retention'] = '15d'

default['prometheus']['cli_flags'] = ['web.enable-lifecycle']

default['prometheus']['server_role'] = 'prometheus_server'

# Set if server is global
default['prometheus']['is_global'] = false

# Set if server use remote storage
default['prometheus']['use_remote_storage'] = false

# Set datacenters to run google analytics job
default['prometheus']['google_analytics_job']['datacenters'] = ['dal']
