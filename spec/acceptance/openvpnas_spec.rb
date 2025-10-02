# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

describe 'openvpnas class' do
  context 'with default parameters' do
    let(:pp) do
      <<-PUPPET
        class { 'openvpnas':
          manage_repo    => false,
          manage_service => false,
        }
      PUPPET
    end

    it 'works idempotently with no errors' do
      idempotent_apply(pp)
    end
  end

  describe 'openvpnas package' do
    it 'is installed' do
      expect(package('openvpn-as')).to be_installed
    end
  end

  describe 'openvpnas service' do
    it 'is running' do
      expect(service('openvpnas')).to be_running
      expect(service('openvpnas')).to be_enabled
    end
  end
end
