require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'

# Define puppet-lint task explicitly
PuppetLint::RakeTask.new(:lint)

# Define metadata-json-lint task if gem is available
begin
  require 'metadata_json_lint/rake_task'
  MetadataJsonLint::RakeTask.new(:metadata_lint)
rescue LoadError
  task :metadata_lint do
    warn 'metadata-json-lint not available; skipping metadata_lint task'
  end
end

task default: [:lint, :metadata_lint, :spec]

