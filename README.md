OpenVPN Access Server (openvpnas) Puppet module
================================================

Overview
--------
Install and configure OpenVPN Access Server. Supports optional repo setup, package version locking, web UI TLS certificate symlinks, and basic configuration via `sacli`.

Usage
-----

1) Basic
```puppet
class { 'openvpnas':
  manage_repo => true,
}
```

2) Pin version and enable versionlock
```puppet
class { 'openvpnas':
  manage_repo        => true,
  version            => '3.6.1',
  versionlock_enable => true,
}
```

3) Link Let's Encrypt certs to the web UI
```puppet
class { 'openvpnas':
  manage_web_certs => true,
  cert_source_path => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",
}
```

4) Apply key-value config via `sacli`
```puppet
class { 'openvpnas':
  config => {
    'vpn.server.daemon.enable' => true,
    'sa.company_name'          => 'ACME',
  }
}
```

5) Bulk import JSON config (best-effort)
```puppet
openvpnas::config::import { 'site-config':
  source => 'puppet:///modules/openvpnas/config.json',
}
```

Parameters
----------
- manage_repo (Boolean): manage OpenVPN AS yum repo.
- version (String|Undef): package version to install.
- versionlock_enable (Boolean): enable `yum::versionlock`.
- manage_service (Boolean): manage `openvpnas` service.
- manage_web_certs (Boolean): create LE cert symlinks.
- cert_source_path (String): path with `cert.pem`, `privkey.pem`, `fullchain.pem`.
- config (Hash|Undef): sacli keys to apply.

Compatibility
-------------
- AlmaLinux 9

Testing
-------
- Unit/style/integration: `bundle exec rake test`
- Acceptance (Docker): `bundle exec rake acceptance:local docker_set=centos9`

License
-------
Apache-2.0

