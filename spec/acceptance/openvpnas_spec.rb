require 'spec_helper_acceptance'

describe 'openvpnas class on AlmaLinux 9' do
  it 'applies idempotently' do
    pp = <<-MANIFEST
      class { 'openvpnas':
        manage_repo => false,
        manage_service => false,
      }
    MANIFEST

    idempotent_apply(pp)
  end
end


