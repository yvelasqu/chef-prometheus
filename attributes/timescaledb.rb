# TimescaleDB version to build
default['prometheus']['timescaledb']['version'] = '0.9.1'

# Location for TimescaleDB pre-compiled binary.
default['prometheus']['timescaledb']['binary_host'] = 'https://repo.prod.lan.com/timescale'
default['prometheus']['timescaledb']['binary_url'] = "#{node['prometheus']['timescaledb']['binary_host']}/timescaledb-#{node['prometheus']['timescaledb']['version']}-postgresql-10-0.x86_64.rpm"

# Checksum for pre-compiled binary
default['prometheus']['timescaledb']['checksum'] = 'd1751a521087e4c8099285a0e200e21674e81b77a6673cc6e4ffb28011022c6a'
