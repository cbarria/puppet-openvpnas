# Managed by modulesync - DO NOT EDIT
# https://voxpupuli.org/docs/updating-files-managed-with-modulesync/

# Attempt to load voxpupuli-test (which pulls in puppetlabs_spec_helper)
begin
  require 'voxpupuli/test/rake'
rescue LoadError
  # voxpupuli-test unavailable
end

begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
  # voxpupuli-acceptance unavailable
end

begin
  require 'puppet_blacksmith/rake_tasks'
rescue LoadError
  # puppet_blacksmith unavailable
end
