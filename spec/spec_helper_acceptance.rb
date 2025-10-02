# frozen_string_literal: true

require 'voxpupuli/acceptance/spec_helper_acceptance'

configure_beaker do |host|
  install_puppet_on(host, puppet_collection: 'puppet8') unless ENV['BEAKER_provision'] == 'no'
  install_module_on(host)
  install_module_dependencies_on(host)
end
