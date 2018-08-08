require 'spec_helper'

describe 'chef-prometheus::alertmanager' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :all do
      stub_command('/opt/prometheus/alertmanager/alertmanager --version 2>&1 | grep alertmanager | grep -F 0.14.0')
        .and_return(true)
    end

    it 'should not download it' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/alertmanager-0.14.0.tar.gz")
    end
  end

  context 'it is not installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :all do
      stub_command('/opt/prometheus/alertmanager/alertmanager --version 2>&1 | grep alertmanager | grep -F 0.14.0')
        .and_return(false)
    end

    it 'should create installation directory /opt/prometheus/alertmanager' do
      expect(chef_run).to create_directory('/opt/prometheus/alertmanager').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should create data directory /opt/prometheus/alertmanager/data' do
      expect(chef_run).to create_directory('/opt/prometheus/alertmanager/data').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should create logging directory /var/log/alertmanager' do
      expect(chef_run).to create_directory('/var/log/alertmanager').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/alertmanager-0.14.0.tar.gz")
    end

    it 'should install it' do
      download_prometheus = chef_run.remote_file("#{Chef::Config[:file_cache_path]}/alertmanager-0.14.0.tar.gz")
      expect(download_prometheus).to notify('execute[install_alertmanager]').to(:run).immediately
    end

    it 'should create its configuration file' do
      expect(chef_run).to create_template('/opt/prometheus/alertmanager/config.yml').with(
        owner: 'root',
        group: 'root',
        mode: '0644'
      )
    end

    it 'should register its service' do
      expect(chef_run).to create_template('/etc/init.d/alertmanager').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should start its service' do
      expect(chef_run).to start_service('alertmanager')
    end
  end
end
