begin
  require 'voxpupuli/test/rake'
rescue LoadError
  warn 'voxpupuli-test not available; install bundle to run tests'
end
begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
  warn 'voxpupuli-acceptance not available; skipping acceptance tasks'
end

task default: [:test]

