require 'spec_helper'

describe 'chef-prometheus::node_exporter' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :all do
      stub_command('/opt/prometheus/node_exporter/node_exporter --version 2>&1 | grep node_exporter | grep -F 0.15.2')
        .and_return(true)
    end

    it 'should not download it' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/node_exporter-0.15.2.tar.gz")
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
      stub_command('/opt/prometheus/node_exporter/node_exporter --version 2>&1 | grep node_exporter | grep -F 0.15.2')
        .and_return(false)
    end

    it 'should create installation directory /opt/prometheus/node_exporter' do
      expect(chef_run).to create_directory('/opt/prometheus/node_exporter').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should create logging directory /var/log/node_exporter' do
      expect(chef_run).to create_directory('/var/log/node_exporter').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should download needed os packages' do
      expect(chef_run).to install_package('glibc-static')
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/node_exporter-0.15.2.tar.gz")
    end

    it 'should install it' do
      download_prometheus = chef_run.remote_file("#{Chef::Config[:file_cache_path]}/node_exporter-0.15.2.tar.gz")
      expect(download_prometheus).to notify('execute[install_node_exporter]').to(:run).immediately
    end

    it 'should register its service' do
      expect(chef_run).to create_template('/etc/init.d/node_exporter').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should start its service' do
      expect(chef_run).to start_service('node_exporter')
    end
  end
end
