require 'spec_helper'

describe 'openvpnas::config::key' do
  let(:title) { 'vpn.server.daemon.enable' }
  let(:params) do
    { key: 'vpn.server.daemon.enable', value: true }
  end

  it { is_expected.to compile.with_all_deps }

  it 'creates exec to set key' do
    is_expected.to contain_exec('openvpnas-set-vpn.server.daemon.enable')
      .with_command(%r{sacli -k vpn.server.daemon.enable -v 'true' ConfigPut})
  end
end



