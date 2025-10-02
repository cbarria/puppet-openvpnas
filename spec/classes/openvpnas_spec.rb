# frozen_string_literal: true

require 'spec_helper'

describe 'openvpnas' do
  on_supported_os.each do |os, os_facts|
    context "when on #{os}" do
      let(:facts) { os_facts }

      context 'with defaults' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_package('openvpn-as').with_ensure('present') }
        it { is_expected.to contain_service('openvpnas').with_enable(true) }
      end

      context 'with repo managed' do
        let(:params) do
          { manage_repo: true }
        end

        it { is_expected.to contain_yumrepo('as-repo-rhel9') }
      end

      context 'with versionlock' do
        let(:params) do
          { versionlock_enable: true, version: '3.6.1' }
        end

        it { is_expected.to contain_class('yum::plugin::versionlock') }
        it { is_expected.to contain_yum__versionlock('openvpn-as').with_version('3.6.1') }
      end

      context 'with manage_web_certs' do
        let(:params) do
          { manage_web_certs: true }
        end

        it { is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/server.crt') }
        it { is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/server.key') }
        it { is_expected.to contain_file('/usr/local/openvpn_as/etc/web-ssl/ca.crt') }
      end

      context 'with config hash' do
        let(:params) do
          { config: { 'vpn.server.daemon.enable' => true, 'sa.company_name' => 'LSST' } }
        end

        it { is_expected.to contain_openvpnas__config__key('vpn.server.daemon.enable').with_value(true) }
        it { is_expected.to contain_openvpnas__config__key('sa.company_name').with_value('LSST') }
      end
    end
  end
end
