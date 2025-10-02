# openvpnas

[![CI](https://github.com/cbarria/puppet-openvpnas/actions/workflows/ci.yml/badge.svg)](https://github.com/cbarria/puppet-openvpnas/actions/workflows/ci.yml)
[![Puppet Forge](https://img.shields.io/puppetforge/v/cbarria/openvpnas.svg)](https://forge.puppet.com/cbarria/openvpnas)
[![Puppet Forge Downloads](https://img.shields.io/puppetforge/dt/cbarria/openvpnas.svg)](https://forge.puppet.com/cbarria/openvpnas)
[![License](https://img.shields.io/github/license/cbarria/puppet-openvpnas.svg)](https://github.com/cbarria/puppet-openvpnas/blob/main/LICENSE)

## Table of Contents

1. [Description](#description)
1. [Setup](#setup)
1. [Usage](#usage)
   - [Basic Installation](#basic-installation)
   - [Repository Management](#repository-management)
   - [Version Locking](#version-locking)
   - [TLS Certificate Management](#tls-certificate-management)
   - [Configuration Management](#configuration-management)
   - [Bulk Configuration Import](#bulk-configuration-import)
   - [Complete Example](#complete-example)
1. [Reference](#reference)
1. [Limitations](#limitations)
1. [Development](#development)

## Description

This module manages OpenVPN Access Server (AS) installation and
configuration on RHEL-based systems. It provides comprehensive management
capabilities including:

- Repository management for official OpenVPN AS packages
- Package version locking to prevent unwanted upgrades
- Service management with enable/disable options
- TLS certificate integration with Let's Encrypt or other providers
- Configuration management through the `sacli` command-line interface
- Bulk configuration import from JSON files
- Idempotent operations with change detection

OpenVPN Access Server is the commercial VPN solution from OpenVPN Inc.,
offering a web-based administration interface and easier setup compared to
the community edition.

## Setup

### What openvpnas affects

This module manages the following system components:

- OpenVPN Access Server package (`openvpn-as`) installation
- YUM repository configuration at `/etc/yum.repos.d/openvpn-access-server.repo`
- Package version locks via YUM versionlock plugin
- OpenVPN Access Server service (`openvpnas`)
- Web UI TLS certificate symlinks at `/usr/local/openvpn_as/etc/web-ssl/`
- Configuration database via `sacli` commands

### Setup Requirements

This module has the following dependencies:

- Puppet >= 7.0.0
- puppetlabs/stdlib >= 9.0.0

When using version locking features:

- puppet/yum >= 8.0.0

All dependencies are automatically installed when installing from Puppet Forge.

### Beginning with openvpnas

The simplest use case is to install OpenVPN Access Server with default settings:

```puppet
include openvpnas
```

This installs the package from your system's configured repositories without
managing the OpenVPN AS repository or service.

## Usage

### Basic Installation

Install OpenVPN AS and enable the service:

```puppet
class { 'openvpnas':
  manage_repo    => true,
  manage_service => true,
}
```

This configuration:

- Configures the official OpenVPN AS yum repository
- Installs the latest available `openvpn-as` package
- Ensures the `openvpnas` service is running and enabled at boot

### Repository Management

The module can manage the official OpenVPN AS repository. By default, it
uses the RHEL 9 repository, but you can customize it:

```puppet
class { 'openvpnas':
  manage_repo      => true,
  yumrepo_baseurl  => 'http://as-repository.openvpn.net/as/yum/rhel9/',
  yumrepo_id       => 'as-repo-rhel9',
  yumrepo_name     => 'openvpn-access-server',
  gpgkey_url       => 'https://as-repository.openvpn.net/as-repo-public.gpg',
}
```

If you have your own mirror or specific repository requirements, adjust
these parameters accordingly.

### Version Locking

Pin OpenVPN AS to a specific version to prevent automatic upgrades:

```puppet
class { 'openvpnas':
  manage_repo        => true,
  version            => '2.13.1',
  versionlock_enable => true,
  versionlock_release => '1.el9',
}
```

Version locking is useful for:

- Production stability where you need to control upgrade timing
- Ensuring compatibility with specific configurations or integrations
- Meeting compliance requirements for change control

The `versionlock_release` parameter corresponds to the RPM release string
and typically follows the pattern `1.el9` for RHEL 9.

### TLS Certificate Management

Integrate OpenVPN AS web UI with Let's Encrypt or other certificate providers:

```puppet
class { 'openvpnas':
  manage_web_certs => true,
  cert_source_path => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",
}
```

This creates symlinks in `/usr/local/openvpn_as/etc/web-ssl/`:

- `server.crt` -> `cert.pem` (server certificate)
- `server.key` -> `privkey.pem` (private key)
- `ca.crt` -> `fullchain.pem` (certificate chain)

The module automatically notifies the service to restart when certificates
change, ensuring the web UI always uses current certificates.

Example with Certbot integration:

```puppet
# Manage Let's Encrypt certificate
class { 'letsencrypt':
  email => 'admin@example.com',
}

letsencrypt::certonly { $facts['networking']['fqdn']:
  domains => [$facts['networking']['fqdn']],
  plugin  => 'standalone',
}

# Configure OpenVPN AS to use the certificate
class { 'openvpnas':
  manage_repo      => true,
  manage_web_certs => true,
  cert_source_path => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",
  require          => Letsencrypt::Certonly[$facts['networking']['fqdn']],
}
```

### Configuration Management

OpenVPN AS configuration is managed through the `sacli` command-line tool.
This module provides two methods for configuration:

#### Individual Configuration Keys

Configure specific settings using the `config` parameter:

```puppet
class { 'openvpnas':
  manage_repo => true,
  config      => {
    'vpn.server.daemon.enable'     => true,
    'vpn.server.daemon.tcp.port'   => 443,
    'vpn.server.daemon.udp.port'   => 1194,
    'sa.company_name'              => 'Example Corporation',
    'host.name'                    => $facts['networking']['fqdn'],
    'cs.tls_version_min'           => '1.2',
    'cs.tls_version_min_strict'    => true,
  },
}
```

Each key-value pair is applied using `sacli ConfigPut` and automatically
restarts the service if changes are detected.

Common configuration keys include:

- `vpn.server.daemon.enable`: Enable/disable VPN daemon
- `vpn.server.daemon.tcp.port`: TCP port for VPN connections
- `vpn.server.daemon.udp.port`: UDP port for VPN connections
- `host.name`: Hostname for certificates and web UI
- `sa.company_name`: Company name displayed in web UI
- `cs.tls_version_min`: Minimum TLS version
- `vpn.client.routing.reroute_gw`: Enable/disable default gateway redirect

Consult the OpenVPN AS documentation for complete configuration reference.

#### Using the Define Type Directly

For more granular control, use the `openvpnas::config::key` define:

```puppet
openvpnas::config::key { 'vpn.server.daemon.tcp.port':
  key   => 'vpn.server.daemon.tcp.port',
  value => 443,
}

openvpnas::config::key { 'enable-web-admin':
  key   => 'cs.admin_ui.allow_proxy',
  value => true,
}
```

This is useful when:

- Managing configuration from multiple classes or modules
- Conditionally applying configuration based on facts
- Creating reusable configuration profiles

### Bulk Configuration Import

For complex configurations or migrating settings between servers, use JSON import:

```puppet
openvpnas::config::import { 'production-config':
  source => 'puppet:///modules/mymodule/openvpn-as-config.json',
}
```

The JSON file should contain the complete configuration database as
exported by `sacli ConfigQuery`.

Example JSON structure:

```json
{
  "vpn.server.daemon.enable": true,
  "vpn.server.daemon.tcp.port": 443,
  "host.name": "vpn.example.com",
  "sa.company_name": "Example Corp"
}
```

To export current configuration from a running server:

```bash
/usr/local/openvpn_as/scripts/sacli ConfigQuery > config.json
```

Optional parameter `refresh_on_change` controls whether to restart services
after import (default: `true`):

```puppet
openvpnas::config::import { 'staging-config':
  source            => 'puppet:///modules/mymodule/staging-config.json',
  refresh_on_change => false,
}
```

### Complete Example

Production-ready configuration with all features:

```puppet
# Configure OpenVPN AS with version locking, TLS, and custom settings
class { 'openvpnas':
  # Repository and package management
  manage_repo         => true,
  version             => '2.13.1',
  versionlock_enable  => true,

  # Service management
  manage_service      => true,

  # TLS certificate integration
  manage_web_certs    => true,
  cert_source_path    => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",

  # Base configuration
  config              => {
    'host.name'                     => $facts['networking']['fqdn'],
    'sa.company_name'               => 'Example Corporation',
    'vpn.server.daemon.enable'      => true,
    'vpn.server.daemon.tcp.port'    => 443,
    'vpn.server.daemon.udp.port'    => 1194,
    'vpn.client.routing.reroute_gw' => true,
    'cs.tls_version_min'            => '1.2',
  },
}

# Import additional configuration
openvpnas::config::import { 'network-config':
  source => 'puppet:///modules/profiles/openvpn/network-settings.json',
}
```

### FreeIPA/LDAP Integration

For environments using FreeIPA or LDAP for centralized authentication:

```puppet
# OpenVPN AS with FreeIPA authentication
class { 'openvpnas':
  manage_repo    => true,
  manage_service => true,
  config         => {
    # FreeIPA/LDAP authentication
    'auth.module.type'              => 'ldap',
    'auth.ldap.0.server.0.host'     => 'ipa.example.com',
    'auth.ldap.0.bind_dn'           => 'uid=openvpn-svc,cn=users,cn=accounts,dc=example,dc=com',
    'auth.ldap.0.bind_pw'           => 'service_account_password',
    'auth.ldap.0.users_base_dn'     => 'cn=users,cn=accounts,dc=example,dc=com',
    'auth.ldap.0.use_ssl'           => 'always',
    'auth.ldap.0.ssl_verify'        => 'host',
    'auth.ldap.0.timeout'           => '4',
    'auth.ldap.0.name'              => 'FreeIPA Authentication',

    # Network configuration
    'host.name'                     => $facts['networking']['fqdn'],
    'vpn.server.daemon.enable'      => true,
    'vpn.server.daemon.tcp.port'    => 443,
    'vpn.server.daemon.udp.port'    => 1194,

    # Routing - allow access to private networks
    'vpn.server.routing.private_access'    => 'nat',
    'vpn.server.routing.private_network.0' => '10.0.0.0/8',
    'vpn.server.routing.private_network.1' => '172.16.0.0/12',
    'vpn.server.routing.private_network.2' => '192.168.0.0/16',

    # Client routing
    'vpn.client.routing.reroute_gw'       => true,
    'vpn.client.routing.reroute_dns'      => true,

    # Security settings
    'cs.tls_version_min'                   => '1.2',
    'vpn.server.tls_cc_security'           => 'tls-crypt',
  },
}
```

**Benefits of FreeIPA integration:**

- Users and groups managed centrally in FreeIPA
- Single Sign-On (SSO) with Kerberos
- Group-based VPN access policies
- Simplified disaster recovery (only configuration backup needed)
- Automatic user provisioning/deprovisioning

**Backup strategy with LDAP:**

```bash
# Only configuration backup needed (users are in FreeIPA)
sudo /usr/local/openvpn_as/scripts/sacli ConfigQuery > openvpn-config.json

# Optional: backup certificates
sudo tar -czf openvpn-certs.tar.gz /usr/local/openvpn_as/etc/web-ssl/
```

## Reference

See [REFERENCE.md](REFERENCE.md) for complete parameter documentation.

### Main Class Parameters

- `manage_repo`: Boolean to enable repository management (default: `false`)
- `version`: String specifying package version (default: `undef` for latest)
- `versionlock_enable`: Boolean to enable version locking (default: `false`)
- `manage_service`: Boolean to manage service state (default: `true`)
- `manage_web_certs`: Boolean to manage TLS certificate symlinks
  (default: `false`)
- `cert_source_path`: String path to certificate directory
  (default: Let's Encrypt path)
- `config`: Hash of configuration key-value pairs (default: `undef`)

### Defined Types

#### openvpnas::config::key

Manages individual configuration keys through `sacli`.

Parameters:

- `key`: Configuration key name (required)
- `value`: Configuration value - supports String, Integer, or Boolean (required)

#### openvpnas::config::import

Imports bulk configuration from JSON file.

Parameters:

- `source`: Puppet file source path (required)
- `refresh_on_change`: Boolean to restart service after import (default: `true`)

## Limitations

Tested and supported platforms:

- AlmaLinux 9
- CentOS 9 Stream
- Rocky Linux 9 (should work but not CI tested)

This module is designed specifically for OpenVPN Access Server, not the
open-source OpenVPN Community Edition. The two products have different
installation methods, configuration systems, and management tools.

Limitations and known issues:

- Initial password for `openvpn` user must be set manually after first
  installation
- Web UI will be unavailable until admin password is configured
- Repository management currently only supports RHEL 9 family
  (configurable for other versions)
- Configuration changes may require service restart which briefly interrupts
  VPN connections
- TLS certificate management assumes Let's Encrypt directory structure

## Development

This module follows Voxpupuli standards and best practices.

### Contributing

Contributions are welcome. Please:

1. Fork the repository
1. Create a feature branch from `main`
1. Write tests for new functionality
1. Ensure all tests pass locally
1. Submit a pull request with clear description

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

### Running Tests

Install dependencies:

```bash
bundle install
```

Run all tests:

```bash
bundle exec rake test
```

Run specific test suites:

```bash
# Unit tests only
bundle exec rake spec

# Acceptance tests with Docker
bundle exec rake beaker

# Linting and syntax validation
bundle exec rake lint
bundle exec rake syntax
bundle exec rake rubocop
```

Generate reference documentation:

```bash
bundle exec rake strings:generate:reference
```

### Code Quality

This module uses:

- RSpec-Puppet for unit testing
- Beaker for acceptance testing
- Puppet Lint for Puppet code style
- RuboCop for Ruby code style
- GitHub Actions for continuous integration

All pull requests must pass CI checks before merging.

## License

Apache-2.0 - See [LICENSE](LICENSE) file for details.

## Authors

- Carlos Barria

## Support

For issues, questions, or contributions, please use the
[GitHub issue tracker](https://github.com/cbarria/puppet-openvpnas/issues).
