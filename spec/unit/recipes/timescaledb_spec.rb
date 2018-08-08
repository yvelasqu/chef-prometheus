require 'spec_helper'

describe 'chef-prometheus::timescaledb' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before do
      stub_command("cat /var/lib/pgsql/10/data/postgresql.conf | grep -F \"shared_preload_libraries = 'timescaledb'\"")
        .and_return(true)
      stub_command("psql -d prometheus -c '\\dx' | grep -F timescaledb")
        .and_return(true)
      stub_command("rpm -qa | grep -F 'timescaledb' | grep -F 0.9.1")
        .and_return(true)
    end

    it 'should not download it' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/timescaledb-0.9.1.rpm")
    end
  end

  context 'it is not installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before do
      stub_command("cat /var/lib/pgsql/10/data/postgresql.conf | grep -F \"shared_preload_libraries = 'timescaledb'\"")
        .and_return(false)
      stub_command("psql -d prometheus -c '\\dx' | grep -F timescaledb")
        .and_return(false)
      stub_command("rpm -qa | grep -F 'timescaledb' | grep -F 0.9.1")
        .and_return(false)
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/timescaledb-0.9.1.rpm")
    end

    it 'should add it in repositories' do
      expect(chef_run).to install_rpm_package('timescaledb')
    end

    it 'should install packages' do
      expect(chef_run).to install_yum_package('timescaledb')
    end

    it 'should setup it' do
      expect(chef_run).to create_template('/var/lib/pgsql/10/data/postgresql.conf').with(
        source: 'configuration/database/postgresql.conf.erb',
        user: 'postgres',
        group: 'postgres',
        mode: '0600'
      )
    end

    it 'should install it' do
      expect(chef_run).to run_execute('create_timescale_extension').with(
        user: 'postgres',
        group: 'postgres',
        command: "psql -d prometheus -c 'CREATE EXTENSION timescaledb CASCADE;'"
      )
    end

    it 'should restart postgresql service' do
      restart_postgresql = chef_run.execute('restart_postgresql')
      expect(restart_postgresql.user).to eq('root')
      expect(restart_postgresql.group).to eq('root')
      expect(restart_postgresql.command).to eq('systemctl restart postgresql-10')
      expect(restart_postgresql).to do_nothing
    end
  end
end
