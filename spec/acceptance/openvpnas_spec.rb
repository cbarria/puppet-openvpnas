# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

# rubocop:disable RSpec/DescribeClass
describe 'openvpnas class' do
  hosts.each do |host|
    context "when on #{host}" do
      let(:pp) do
        <<-MANIFEST
          class { 'openvpnas':
            manage_repo       => false,
            manage_service    => false,
          }
        MANIFEST
      end

      it 'applies with no errors' do
        idempotent_apply(pp)
      end
    end
  end
end
# rubocop:enable RSpec/DescribeClass

