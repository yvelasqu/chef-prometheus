require 'spec_helper'

describe 'chef-prometheus::configure_postgresql_adapter' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before do
      stub_command('test -f /opt/prometheus/database/postgresql_adapter')
        .and_return(true)
    end

    it 'should not create it' do
      expect(chef_run).not_to create_cookbook_file('/opt/prometheus/database/postgresql_adapter')
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
      stub_command('test -f /opt/prometheus/database/postgresql_adapter')
        .and_return(false)
    end

    it 'should create log directory /var/log/postgresql_adapter' do
      expect(chef_run).to create_directory('/var/log/postgresql_adapter').with(
        owner: 'root',
        group: 'root',
        mode: '0755'
      )
    end

    it 'should create it' do
      expect(chef_run).to create_cookbook_file('/opt/prometheus/database/postgresql_adapter').with(
        user: 'root',
        group: 'root',
        mode: '0755',
        source: 'binaries/prometheus-postgresql-adapter/prometheus-postgresql-adapter'
      )
    end

    it 'should create service' do
      expect(chef_run).to create_template('/etc/init.d/postgresql_adapter').with(
        user: 'root',
        group: 'root',
        mode: '0755',
        source: 'service/postgresql_adapter.erb'
      )
    end

    it 'should start its service' do
      expect(chef_run).to start_service('postgresql_adapter')
    end
  end
end
