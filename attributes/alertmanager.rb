# Directory where the Alert Manager binary will be installed
default['prometheus']['alertmanager']['dir'] = '/opt/prometheus/alertmanager'

# Location of Alert Manager binary
default['prometheus']['alertmanager']['binary'] = "#{node['prometheus']['alertmanager']['dir']}/alertmanager"

# Location of Alert Manager pid file
default['prometheus']['alertmanager']['pid'] = '/var/run/alertmanager.pid'

# Location for Alert Manager logs
default['prometheus']['alertmanager']['log_dir'] = '/var/log/alertmanager'

# Location for Alert Manager data
default['prometheus']['alertmanager']['data_dir'] = "#{node['prometheus']['alertmanager']['dir']}/data"

# Alert Manager version to build
default['prometheus']['alertmanager']['version'] = '0.14.0'

# Location for Alert Manager pre-compiled binary.
default['prometheus']['alertmanager']['binary_url'] = "https://github.com/prometheus/alertmanager/releases/download/v#{node['prometheus']['alertmanager']['version']}/alertmanager-#{node['prometheus']['alertmanager']['version']}.linux-amd64.tar.gz"

# Checksum for pre-compiled binary
default['prometheus']['alertmanager']['checksum'] = 'caddbbbe3ef8545c6cefb32f9a11207ae18dcc788e8d0fb19659d88c58d14b37'

# Location for Alert Manager config file
default['prometheus']['alertmanager']['config_file'] = "#{node['prometheus']['alertmanager']['dir']}/config.yml"

# Slack Alertmanager
default['prometheus']['alertmanager']['slack_webhook'] = ''
