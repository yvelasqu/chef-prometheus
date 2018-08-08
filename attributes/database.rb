# Directory where the Prometheus database settings will be installed
default['prometheus']['database']['dir'] = '/opt/prometheus/database'

# Directory where the PostgreSQL data will be installed
default['prometheus']['database']['data_dir'] = '/var/lib/pgsql/10/data'

# Location of PostgreSQL binary
default['prometheus']['database']['binary'] = '/usr/pgsql-10/bin/postgres'

# PostgreSQL version
default['prometheus']['database']['version'] = '10.3'

# Location for PostgreSQL pre-compiled binary.
default['prometheus']['database']['binary_url'] = 'https://download.postgresql.org/pub/repos/yum/10/redhat/rhel-7-x86_64/pgdg-centos10-10-2.noarch.rpm'

# Checksum for PostgreSQL pre-compiled binary
default['prometheus']['database']['checksum'] = '78746da98377f57e5dfe9614d5ab1d320081486351de65244c238da79d3c0733'

# Location of PostgreSQL Adapter binary
default['prometheus']['database']['adapter']['binary'] = "#{node['prometheus']['database']['dir']}/postgresql_adapter"

# Location of PostgreSQL Adapter pid file
default['prometheus']['database']['adapter']['pid'] = '/var/run/postgresql_adapter'

# Location for PostgreSQL Adapter logs
default['prometheus']['database']['adapter']['log_dir'] = '/var/log/postgresql_adapter'

# Role for database
default['prometheus']['database']['server_role'] = 'prometheus_database'

# Directory where the PG Prometheus will be installed
default['prometheus']['database']['pg_prometheus']['dir'] = '/opt/prometheus/database/pg_prometheus'

# PG Prometheus version to build
default['prometheus']['database']['pg_prometheus']['version'] = '0.1'

# Location for PG Prometheus pre-compiled binary.
default['prometheus']['database']['pg_prometheus']['binary_url'] = "https://github.com/timescale/pg_prometheus/archive/#{node['prometheus']['database']['pg_prometheus']['version']}.tar.gz"

# Checksum for PG Prometheus pre-compiled binary
default['prometheus']['database']['pg_prometheus']['checksum'] = 'efa2d5ef388e1474b9559422aa94f79ed6d4be7760e7f8bbf5ef05c19ecdc9b6'

# Master database
default['prometheus']['database']['master'] = false

# Prometheus User Database
default['prometheus']['database']['password'] = 'changeme'

# Cli options
default['prometheus']['database']['cli_opts']['pg.host'] = '127.0.0.1'
default['prometheus']['database']['cli_opts']['pg.user'] = 'prometheus'
default['prometheus']['database']['cli_opts']['pg.database'] = 'prometheus'
