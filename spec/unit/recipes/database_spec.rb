require 'spec_helper'

describe 'chef-prometheus::database' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :each do
      hosts = [{
        'hostname' => 'node1.latam.com',
        'backendipaddress' => '10.0.0.1',
        'ipaddress' => '50.0.0.1'
      }]

      stub_command('/usr/pgsql-10/bin/postgres --version 2>&1 | grep postgres | grep -F 10.3')
        .and_return(true)
      stub_command('cat /var/lib/pgsql/10/data/postgresql.conf | grep -F "wal_level = replica"')
        .and_return(true)
      stub_command("cat /var/lib/pgsql/10/data/postgresql.conf | grep -F \"shared_preload_libraries = 'timescaledb'\"")
        .and_return(true)
      stub_command("rpm -qa | grep -F 'timescaledb' | grep -F 0.9.1")
        .and_return(true)
      stub_command('test -f /opt/prometheus/database/postgresql_adapter')
        .and_return(true)
      stub_command("PGPASSWORD=changeme psql -U prometheus -h 127.0.0.1 -d prometheus -c '\\dx' | grep -F pg_prometheus")
        .and_return(true)
      stub_command("psql -d prometheus -c '\\dx' | grep -F timescaledb")
        .and_return(true)
      stub_command("psql -d prometheus -c 'SELECT * FROM pg_replication_slots' | grep -F 'replica_1_slot'")
        .and_return(true)
      stub_command("psql -c '\\l' postgres | grep prometheus")
        .and_return(true)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_database')
        .and_return(hosts)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_database AND master:true')
        .and_return(hosts)
    end

    it 'should not download it' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/postgresql-10.3.rpm")
    end

    it 'should not download pg_prometheus extension' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/pg_prometheus-0.1.tar.gz")
    end
  end

  context 'it is not installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
        node.override['prometheus']['database']['master'] = true
      end.converge(described_recipe)
    end

    before :each do
      hosts = [{
        'hostname' => 'node1.latam.com',
        'backendipaddress' => '10.0.0.1',
        'ipaddress' => '50.0.0.1'
      }]

      stub_command('/usr/pgsql-10/bin/postgres --version 2>&1 | grep postgres | grep -F 10.3')
        .and_return(false)
      stub_command('cat /var/lib/pgsql/10/data/postgresql.conf | grep -F "wal_level = replica"')
        .and_return(false)
      stub_command("cat /var/lib/pgsql/10/data/postgresql.conf | grep -F \"shared_preload_libraries = 'timescaledb'\"")
        .and_return(false)
      stub_command('postgresql-setup initdb')
        .and_return(true)
      stub_command("rpm -qa | grep -F 'timescaledb' | grep -F 0.9.1")
        .and_return(false)
      stub_command('test -f /opt/prometheus/database/postgresql_adapter')
        .and_return(false)
      stub_command("PGPASSWORD=changeme psql -U prometheus -h 127.0.0.1 -d prometheus -c '\\dx' | grep -F pg_prometheus")
        .and_return(false)
      stub_command("psql -d prometheus -c '\\dx' | grep -F timescaledb")
        .and_return(false)
      stub_command("psql -d prometheus -c 'SELECT * FROM pg_replication_slots' | grep -F 'replica_1_slot'")
        .and_return(false)
      stub_command("psql -c '\\l' postgres | grep prometheus")
        .and_return(false)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_database')
        .and_return(hosts)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_database AND master:true')
        .and_return(hosts)
    end

    it 'should create database directory /opt/prometheus/database' do
      expect(chef_run).to create_directory('/opt/prometheus/database').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/postgresql-10.3.rpm")
    end

    it 'should add it in repositories' do
      expect(chef_run).to install_rpm_package('postgresql10-server')
    end

    it 'should install it' do
      expect(chef_run).to install_yum_package('postgresql10-server')
    end

    it 'should setup it' do
      setup_postgresql = chef_run.execute('setup_postgresql')
      expect(setup_postgresql.command).to eq('/usr/pgsql-10/bin/postgresql-10-setup initdb')
      expect(setup_postgresql).to notify('service[postgresql-10]').to(:start).immediately
      expect(setup_postgresql).to do_nothing
    end

    it 'should create prometheus user' do
      create_user = chef_run.execute('create_prometheus_user')
      expect(create_user.user).to eq('postgres')
      expect(create_user.group).to eq('postgres')
      expect(create_user.command).to eq('(cat - << _EOF
changeme
changeme
_EOF
) | createuser -s -P --replication --login prometheus')
      expect(create_user).to do_nothing
    end

    it 'should update host-based authentication file' do
      create_pg_hba = chef_run.template('/var/lib/pgsql/10/data/pg_hba.conf')
      expect(create_pg_hba.mode).to eq('0600')
      expect(create_pg_hba.user).to eq('postgres')
      expect(create_pg_hba.group).to eq('postgres')
      expect(create_pg_hba.source).to eq('configuration/database/pg_hba.conf.erb')
      expect(create_pg_hba).to notify('service[postgresql-10]').to(:restart).immediately
      expect(create_pg_hba.action).to eq([:create])
    end

    it 'should create database prometheus' do
      create_database_prometheus = chef_run.execute('create_database_prometheus')
      expect(create_database_prometheus.user).to eq('postgres')
      expect(create_database_prometheus.group).to eq('postgres')
      expect(create_database_prometheus.action).to eq([:run])
    end

    it 'should include configure_postgresql_extension' do
      expect(chef_run).to include_recipe('chef-prometheus::configure_postgresql_extension')
    end

    it 'should include timescaledb' do
      expect(chef_run).to include_recipe('chef-prometheus::timescaledb')
    end

    it 'should include configure_postgresql_adapter' do
      expect(chef_run).to include_recipe('chef-prometheus::configure_postgresql_adapter')
    end

    it 'should start its service' do
      expect(chef_run).to start_service('postgresql-10')
    end
  end
end
