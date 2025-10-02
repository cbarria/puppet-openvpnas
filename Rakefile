require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'puppet_blacksmith/rake_tasks' if Bundler.rubygems.find_name('puppet-blacksmith').any?

begin
  require 'voxpupuli/acceptance/rake'
rescue LoadError
  # voxpupuli-acceptance not available
end

PuppetLint.configuration.send('disable_140chars')
PuppetLint.configuration.send('disable_relative')
PuppetLint.configuration.ignore_paths = ['spec/**/*.pp', 'pkg/**/*.pp', 'vendor/**/*.pp']

desc 'Run syntax, lint, and spec tests.'
task test: [
  :metadata_lint,
  :syntax,
  :lint,
  :rubocop,
  :spec,
]

