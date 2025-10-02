# Contributing

## Getting Started

To contribute to this module:

1. Fork the repository
1. Create a feature branch (`git checkout -b my-new-feature`)
1. Make your changes
1. Run tests locally (see below)
1. Commit your changes (`git commit -am 'Add some feature'`)
1. Push to the branch (`git push origin my-new-feature`)
1. Create a new Pull Request

## Running Tests

### Prerequisites

Install Ruby dependencies:

```bash
bundle install
```

### Unit Tests

Run unit tests:

```bash
bundle exec rake test
```

Or run them in parallel:

```bash
bundle exec rake parallel_spec
```

### Acceptance Tests

Run acceptance tests with Docker:

```bash
bundle exec rake acceptance:local docker_set=centos9
```

### Linting and Style

Check syntax and lint:

```bash
bundle exec rake lint
bundle exec rake syntax
bundle exec rake rubocop
```

### Generate Documentation

Generate REFERENCE.md:

```bash
bundle exec rake strings:generate:reference
```

## Code Style

This module follows the
[Puppet Language Style Guide](https://puppet.com/docs/puppet/latest/style_guide.html)
and uses RuboCop for Ruby code.

## Pull Request Guidelines

- Keep changes focused and atomic
- Write clear commit messages
- Update documentation as needed
- Ensure all tests pass
- Add tests for new features
- Update CHANGELOG.md with your changes

## Questions

Open an issue if you have questions or need help!
