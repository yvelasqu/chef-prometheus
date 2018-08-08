require 'spec_helper'

describe 'chef-prometheus::server' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :each do
      stub_command('/opt/prometheus/prometheus --version 2>&1 | grep prometheus | grep -F 2.2.1')
        .and_return(true)

      hosts = [{
        'hostname' => 'node1.latam.com',
        'backendipaddress' => '10.0.0.1',
        'ipaddress' => '50.0.0.1'
      }, {
        'hostname' => 'node2.latam.com',
        'backendipaddress' => '10.0.0.2',
        'ipaddress' => '50.0.0.2'
      }]
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_apache_exporter').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_node_exporter').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND recipes:cadvisor').and_return(hosts)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_server').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_sql_exporter').and_return(hosts)
      allow_any_instance_of(Chef::Recipe).to receive(:get_site).and_return('dal')
    end

    it 'should not download prometheus' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/prometheus-2.2.1.tar.gz")
    end
  end

  context 'it is not installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before :each do
      stub_command('/opt/prometheus/prometheus --version 2>&1 | grep prometheus | grep -F 2.2.1')
        .and_return(false)

      hosts = [{
        'hostname' => 'node1.latam.com',
        'backendipaddress' => '10.0.0.1',
        'ipaddress' => '50.0.0.1'
      }, {
        'hostname' => 'node2.latam.com',
        'backendipaddress' => '10.0.0.2',
        'ipaddress' => '50.0.0.2'
      }]
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_apache_exporter').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_node_exporter').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND recipes:cadvisor').and_return(hosts)
      stub_search('node', 'chef_environment:tools AND roles:prometheus_server').and_return(hosts)
      stub_search('node', '(chef_environment:tools OR chef_environment:prod OR chef_environment:production) AND roles:prometheus_sql_exporter').and_return(hosts)
      stub_search('node', 'chef_environment:tools AND role:prometheus_database AND master:true').and_return(hosts)
      allow_any_instance_of(Chef::Recipe).to receive(:get_site).and_return('dal')
    end

    it 'should create installation directory /opt/prometheus' do
      expect(chef_run).to create_directory('/opt/prometheus').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should create logging directory /var/log/prometheus' do
      expect(chef_run).to create_directory('/var/log/prometheus').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should create configuration file /opt/prometheus/prometheus.yml' do
      expect(chef_run).to create_template('/opt/prometheus/prometheus.yml').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should download needed os packages' do
      expect(chef_run).to install_package('curl')
      expect(chef_run).to install_package('tar')
      expect(chef_run).to install_package('bzip2')
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/prometheus-2.2.1.tar.gz")
    end

    it 'should install it' do
      download_prometheus = chef_run.remote_file("#{Chef::Config[:file_cache_path]}/prometheus-2.2.1.tar.gz")
      expect(download_prometheus).to notify('execute[install_prometheus]').to(:run).immediately
    end

    it 'should register its service' do
      expect(chef_run).to create_template('/etc/init.d/prometheus').with(
        owner: 'root',
        group: 'root'
      )
    end

    it 'should start its service' do
      expect(chef_run).to start_service('prometheus')
    end

    it 'should include ulimit recipe' do
      expect(chef_run).to include_recipe('ulimit')
    end

    context 'it is local' do
      cached(:chef_run_local) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
          node.automatic['prometheus']['is_global'] = false
        end.converge(described_recipe)
      end

      it 'should render configuration file /opt/prometheus/prometheus.yml correctly' do
        expect(chef_run_local).to render_file('/opt/prometheus/prometheus.yml').with_content { |content|
          expect(content).to include('node1')
          expect(content).to include('10.0.0.1:9100')
          expect(content).to include('node2')
          expect(content).to include('10.0.0.2:9100')
          expect(content).to include("- job_name: 'node_exporter'")
          expect(content).to include("- job_name: 'cadvisor'")
          expect(content).to include("- job_name: 'apache_exporter'")
        }
      end
    end

    context 'it is global' do
      cached(:chef_run_global) do
        ChefSpec::SoloRunner.new(platform: 'centos', version: '7.3.1611') do |node|
          node.automatic['prometheus']['is_global'] = true
        end.converge(described_recipe)
      end

      it 'should render configuration file /opt/prometheus/prometheus.yml correctly' do
        expect(chef_run_global).to render_file('/opt/prometheus/prometheus.yml').with_content { |content|
          expect(content).to include("- job_name: 'federate'")
          expect(content).to include('10.0.0.1:9090')
          expect(content).to include('10.0.0.2:9090')
        }
      end

      it 'should not render rules configuration file /opt/prometheus/rules.yml' do
        expect(chef_run_global).not_to create_file('/opt/prometheus/rules.yml')
      end
    end
  end
end
