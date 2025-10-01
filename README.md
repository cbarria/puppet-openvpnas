OpenVPN Access Server (openvpnas) Puppet module
================================================

Overview
--------
Gestiona la instalación de OpenVPN Access Server, el repo opcional, version lock, enlaces de certificados para la UI web y configuración básica vía `sacli`.

Estructura
---------
El módulo sigue la estructura de `puppet-htcondor` como referencia ([lsst-it/puppet-htcondor](https://github.com/lsst-it/puppet-htcondor)).

Uso
---

1) Básico
```puppet
class { 'openvpnas':
  manage_repo => true,
}
```

2) Fijar versión y activar versionlock
```puppet
class { 'openvpnas':
  manage_repo         => true,
  version             => '3.6.1',
  versionlock_enable  => true,
}
```

3) Enlazar certificados de Let's Encrypt a la UI web
```puppet
class { 'openvpnas':
  manage_web_certs => true,
  cert_source_path => "/etc/letsencrypt/live/${facts['networking']['fqdn']}",
}
```

4) Declarar configuración clave-valor con `sacli`
```puppet
class { 'openvpnas':
  config => {
    'vpn.server.daemon.enable' => true,
    'sa.company_name'          => 'LSST',
  }
}
```

5) Importar JSON (best-effort)
```puppet
openvpnas::config::import { 'site-config':
  source => 'puppet:///modules/openvpnas/config.json',
}
```

Parámetros principales
----------------------
- manage_repo (Boolean): gestiona repo de AS.
- version (String|Undef): versión del paquete.
- versionlock_enable (Boolean): activa `yum::versionlock`.
- manage_service (Boolean): gestiona servicio `openvpnas`.
- manage_web_certs (Boolean): crea symlinks a certs LE.
- cert_source_path (String): ruta con `cert.pem`, `privkey.pem`, `fullchain.pem`.
- config (Hash|Undef): mapa de claves `sacli` a valores.

Compatibilidad
--------------
- AlmaLinux 9

Tests
-----
- Unit: `bundle exec rake spec`
- Acceptance (skeleton Beaker): ver `spec/acceptance/`

Licencia
--------
Apache-2.0

