require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

RSpec.configure do |c|
  c.formatter = :documentation
  c.default_facts = {
    networking: {
      fqdn: 'vpn.example.org',
    },
    os: {
      family: 'RedHat',
      name: 'AlmaLinux',
      release: {
        full: '9',
        major: '9'
      }
    }
  }
end

