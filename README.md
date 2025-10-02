# openvpnas

[![CI](https://github.com/cbarria/puppet-openvpnas/actions/workflows/ci.yml/badge.svg)](https://github.com/cbarria/puppet-openvpnas/actions/workflows/ci.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cbarria/openvpnas.svg)](https://forge.puppet.com/cbarria/openvpnas)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/cbarria/openvpnas.svg)](https://forge.puppet.com/cbarria/openvpnas)
[![License](https://img.shields.io/github/license/cbarria/puppet-openvpnas.svg)](https://github.com/cbarria/puppet-openvpnas/blob/main/LICENSE)

## Table of Contents

1. [Description](#description)
2. [Setup](#setup)
3. [Usage](#usage)
4. [Reference](#reference)
5. [Limitations](#limitations)
6. [Development](#development)

## Description

This module installs and configures OpenVPN Access Server (AS). It supports:

- Optional repository management
- Package version locking
- Web UI TLS certificate management (e.g., Let's Encrypt)
- Configuration management via `sacli`
- Bulk configuration import from JSON

## Setup

### What openvpnas affects

- OpenVPN Access Server package and service
- YUM repository configuration (optional)
- Package version locks (optional)
- Web UI TLS certificates via symlinks (optional)
- OpenVPN AS configuration via `sacli` (optional)

### Setup Requirements

This module requires:

- Puppet >= 7.0.0
- puppetlabs/stdlib
- puppet/yum
- puppetlabs/concat
- herculesteam/augeasproviders_core
- herculesteam/augeasproviders_shellvar

### Beginning with openvpnas

Basic installation:

```puppet
include openvpnas
```

Or with repository management:

```puppet
class { 'openvpnas':
  manage_repo => true,
}
```

## Usage

### Basic usage

Install OpenVPN AS with default settings:

```puppet
class { 'openvpnas':
  manage_repo => true,
}
```

### Pin package version

Pin to a specific version and enable versionlock:

```puppet
class { 'openvpnas':
  manage_repo        => true,
  version            => '3.6.1',
  versionlock_enable => true,
}
```

### Configure TLS certificates

Link Let's Encrypt certificates to the web UI:

```puppet
class { 'openvpnas':
  manage_web_certs => true,
  cert_source_path => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",
}
```

### Apply configuration

Configure OpenVPN AS using `sacli`:

```puppet
class { 'openvpnas':
  config => {
    'vpn.server.daemon.enable' => true,
    'sa.company_name'          => 'ACME Corp',
    'host.name'                => $facts['networking']['fqdn'],
  },
}
```

### Bulk import configuration

Import configuration from JSON file:

```puppet
openvpnas::config::import { 'site-config':
  source => 'puppet:///modules/openvpnas/config.json',
}
```

## Reference

See [REFERENCE.md](REFERENCE.md) for full parameter documentation.

## Limitations

Currently tested and supported on:

- AlmaLinux 9
- CentOS 9 Stream

This module is designed for OpenVPN Access Server, not the open-source OpenVPN Community Edition.

## Development

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes with tests
4. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Running tests

```bash
# Install dependencies
bundle install

# Run all tests
bundle exec rake test

# Run acceptance tests
bundle exec rake acceptance:local docker_set=centos9

# Run linting
bundle exec rake lint
bundle exec rake rubocop
```

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details.

## Authors

- Carlos Barria

