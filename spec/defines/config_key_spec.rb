# frozen_string_literal: true

require 'spec_helper'

describe 'openvpnas::config::key' do
  let(:title) { 'vpn.server.daemon.enable' }
  let(:params) do
    { key: 'vpn.server.daemon.enable', value: true }
  end

  on_supported_os.each do |os, os_facts|
    context "when on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile.with_all_deps }

      it 'creates exec to set configuration key' do
        expect(catalogue).to contain_exec('openvpnas-set-vpn.server.daemon.enable')
          .with_command(/sacli -k vpn.server.daemon.enable -v 'true' ConfigPut/)
      end
    end
  end
end
