require 'voxpupuli/acceptance/spec_helper_acceptance'

describe 'openvpnas class' do
  hosts.each do |host|
    context "on #{host}" do
      it 'applies with no errors' do
        pp = <<-MANIFEST
          class { 'openvpnas':
            manage_repo       => false,
            manage_service    => false,
          }
        MANIFEST
        idempotent_apply(pp)
      end
    end
  end
end

