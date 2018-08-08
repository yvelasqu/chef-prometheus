require 'spec_helper'

describe 'chef-prometheus::configure_postgresql_extension' do
  context 'it is already installed' do
    cached(:chef_run) do
      ChefSpec::SoloRunner.new(
        platform: 'centos',
        version: '7.3.1611'
      ).converge(described_recipe)
    end

    before do
      stub_command("PGPASSWORD=changeme psql -U prometheus -h 127.0.0.1 -d prometheus -c '\\dx' | grep -F pg_prometheus")
        .and_return(true)
    end

    it 'should not download it' do
      expect(chef_run).not_to create_remote_file("#{Chef::Config[:file_cache_path]}/pg_prometheus-0.1.tar.gz")
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
      stub_command("PGPASSWORD=changeme psql -U prometheus -h 127.0.0.1 -d prometheus -c '\\dx' | grep -F pg_prometheus")
        .and_return(false)
    end

    it 'should download it' do
      expect(chef_run).to create_remote_file("#{Chef::Config[:file_cache_path]}/pg_prometheus-0.1.tar.gz")
    end

    it 'should install it' do
      expect(chef_run).to install_yum_package(['postgresql10-devel', 'gcc'])
    end

    it 'should uncompress it' do
      uncompress_extension = chef_run.execute('uncompress_extension')
      expect(uncompress_extension.cwd).to eq(Chef::Config[:file_cache_path])
      expect(uncompress_extension.command).to eq("tar -xzf #{Chef::Config[:file_cache_path]}/pg_prometheus-0.1.tar.gz")
      expect(uncompress_extension).to notify('bash[make_extension]').to(:run).immediately
      expect(uncompress_extension).to do_nothing
    end

    it 'should make it' do
      make_extension = chef_run.bash('make_extension')
      expect(make_extension.cwd).to eq("#{Chef::Config[:file_cache_path]}/pg_prometheus-0.1")
      expect(make_extension.code).to eq('    export PATH=$PATH:/usr/pgsql-10/bin
    make
    make install
')
      expect(make_extension).to notify('execute[install_extension]').to(:run).immediately
      expect(make_extension).to do_nothing
    end

    it 'should install it' do
      install_extension = chef_run.execute('install_extension')
      expect(install_extension.user).to eq('postgres')
      expect(install_extension.group).to eq('postgres')
      expect(install_extension.command).to eq("psql -d prometheus -c 'CREATE EXTENSION pg_prometheus;'")
      expect(install_extension).to do_nothing
    end
  end
end
