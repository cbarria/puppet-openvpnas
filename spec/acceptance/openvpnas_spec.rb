# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'openvpnas class' do
  context 'with repo and package management' do
    it 'works with no errors' do
      pp = <<-PUPPET
        class { 'openvpnas':
          manage_repo    => true,
          manage_service => false,
        }
      PUPPET

      # Apply the manifest twice (ensure it's idempotent)
      apply_manifest(pp, catch_failures: true)
      apply_manifest(pp, catch_changes: true)
    end
  end
end
