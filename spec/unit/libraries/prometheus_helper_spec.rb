require 'spec_helper'
require_relative '../../../libraries/prometheus_helper'

describe 'prometheus_helper' do
  before do
    @params = {
      'cli_opts' => {
        'config.file' => '/opt/prometheus/prometheus.yml',
        'log.level' => 'info',
        'storage.tsdb.path' => '/var/lib/prometheus'
      },
      'cli_flags' => ['web.enable-lifecycle']
    }
  end

  it 'should generate flags' do
    expected_flags = '--config.file=/opt/prometheus/prometheus.yml --log.level=info --storage.tsdb.path=/var/lib/prometheus --web.enable-lifecycle'

    flags = generate_flags(@params)

    expect(flags).to eq(expected_flags)
  end

  it 'should generate flags with alter prefix' do
    expected_flags = '-config.file=/opt/prometheus/prometheus.yml -log.level=info -storage.tsdb.path=/var/lib/prometheus -web.enable-lifecycle'

    flags = generate_flags(@params, '-')

    expect(flags).to eq(expected_flags)
  end
end
