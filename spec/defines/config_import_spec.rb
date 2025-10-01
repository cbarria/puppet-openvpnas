require 'spec_helper'

describe 'openvpnas::config::import' do
  let(:title) { 'bulk' }
  let(:params) do
    { source: 'puppet:///modules/openvpnas/config.json' }
  end

  it { is_expected.to compile.with_all_deps }

  it 'creates staging file and import exec' do
    is_expected.to contain_file('/usr/local/openvpn_as/etc/tmp-import.json')
      .with_source('puppet:///modules/openvpnas/config.json')

    is_expected.to contain_exec('openvpnas-config-import')
      .that_subscribes_to('File[/usr/local/openvpn_as/etc/tmp-import.json]')
  end
end



