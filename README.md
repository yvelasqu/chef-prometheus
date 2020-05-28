
# Prometheus Cookbook (chef-prometheus)

You can use this cookbook only to take as reference to create your own cookbook.
This is a Chef cookbook to manage Prometheus and its exporters.
For documentation, examples and guides around Prometheus, visit prometheus.io.

### Supported Versions

* Prometheus - version 2.1.0
* AlertManager - version 0.14.0
* Node Exporter - version 0.15.2

### Cookbook Dependencies

* one - version 0.1.4 or newer
* ulimit - version 0.4.0 or newer
* logrotate

### Recipes

* `alertmanager`: installs and configures alertmanager
* `default`: does nothing
* `node_exporter`: installs and configures node exporter
* `apache_exporter`: installs and configures apache exporter
* `server`: installs and configures Prometheus server
* `configure_global_server`: installs and configure Prometheus federate that consume data from Prometheus local servers.
* `configure_local_server`: configure local servers that consume data from each datacenter
* `configure_postgresql_adapter`: configure adapter postgresql
* `configure_postgresql_extension`: configure extension postgresql
* `database`: install and configure database postgresql to Prometheus (historic data prometheus)
* `timescaledb`: install and configure timescale

### Attributes

* `alertmanager`: Alertmanager attributes
* `node_exporter`: Node exporter attributes
* `server`: Prometheus server attributes
* `apache_exporter`: Apache exporter attributes
* `database`: Database attributes
* `timescaledb`: Timescaledb attributes

## Building

The Makefile provides several targets:

dependencies: downloads build dependencies
rubocop: run rubocop lint
foodcritic: run foodcritic lint
chefspec: run the unit tests suite
check: execute all the previous targets

## Notes

* Cookbook one is not public. This cookbook is used to load a library "get_site()" and identify the datacenter of the server.
* Other Cookbooks dependency could be download from Chef Supermarket.

