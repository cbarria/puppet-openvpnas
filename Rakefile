require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata_json_lint/rake_task'

PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'

task default: [:lint, :metadata_lint, :spec]

desc 'Run puppet-lint'
task :lint do
  PuppetLint::RakeTask.new
end

desc 'Run metadata-json-lint'
task :metadata_lint do
  MetadataJsonLint::RakeTask.new
end

