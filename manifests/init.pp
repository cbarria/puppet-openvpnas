# @summary Manage OpenVPN Access Server (openvpnas) installation and basic config
#
# @param manage_repo
#   Whether to manage the OpenVPN Access Server yum repo.
# @param yumrepo_baseurl
#   Base URL of the OpenVPN Access Server repo.
# @param yumrepo_name
#   Human-friendly name for the repo.
# @param yumrepo_id
#   Repo ID.
# @param gpgkey_url
#   URL to the GPG key for the repo.
# @param package_name
#   Name of the package to install (default: openvpn-as).
# @param version
#   Package version to install. If undef, installs latest.
# @param versionlock_enable
#   Enable versionlock for the package.
# @param versionlock_release
#   Release string used by yum::versionlock when locking a specific version.
# @param manage_service
#   Whether to manage and enable the service.
# @param service_name
#   Service resource title/name (default: openvpnas).
# @param manage_web_certs
#   If true, create symlinks for web UI TLS certs to Let's Encrypt paths.
# @param cert_source_path
#   Where the Let's Encrypt certs live (cert.pem, privkey.pem, fullchain.pem).
class openvpnas (
  Boolean $manage_repo           = lookup('openvpnas::manage_repo'),
  String  $yumrepo_baseurl       = lookup('openvpnas::yumrepo_baseurl'),
  String  $yumrepo_name          = lookup('openvpnas::yumrepo_name'),
  String  $yumrepo_id            = lookup('openvpnas::yumrepo_id'),
  String  $gpgkey_url            = lookup('openvpnas::gpgkey_url'),
  String  $package_name          = lookup('openvpnas::package_name'),
  Optional[String] $version      = lookup('openvpnas::version'),
  Boolean $versionlock_enable    = lookup('openvpnas::versionlock_enable'),
  String  $versionlock_release   = lookup('openvpnas::versionlock_release'),
  Boolean $manage_service        = lookup('openvpnas::manage_service'),
  String  $service_name          = lookup('openvpnas::service_name'),
  Boolean $manage_web_certs      = lookup('openvpnas::manage_web_certs'),
  String  $cert_source_path      = lookup('openvpnas::cert_source_path'),
  Optional[Hash] $config         = undef,
)
{
  # Optional repo management
  if $manage_repo {
    yumrepo { $yumrepo_id:
      ensure   => present,
      name     => $yumrepo_name,
      descr    => $yumrepo_name,
      baseurl  => $yumrepo_baseurl,
      gpgkey   => $gpgkey_url,
      gpgcheck => 1,
      enabled  => 1,
    }
  }

  # Optional versionlock
  if $versionlock_enable {
    include yum::plugin::versionlock
    if $version == undef {
      fail('openvpnas::versionlock_enable requires a specific version')
    }
  }

  package { $package_name:
    ensure  => $version ? {
      undef   => present,
      default => $version,
    },
    require => $manage_repo ? {
      true    => Yumrepo[$yumrepo_id],
      default => undef,
    },
    notify  => $versionlock_enable ? {
      true    => Yum::Versionlock[$package_name],
      default => undef,
    },
  }

  if $versionlock_enable {
    yum::versionlock { $package_name:
      ensure  => present,
      version => $version,
      release => $versionlock_release,
      arch    => 'x86_64',
    }
  }

  # Manage web cert symlinks if requested
  if $manage_web_certs {
    file { '/usr/local/openvpn_as/etc/web-ssl/server.crt':
      ensure  => link,
      target  => "${cert_source_path}/cert.pem",
      force   => true,
      require => Package[$package_name],
      notify  => Service[$service_name],
    }

    file { '/usr/local/openvpn_as/etc/web-ssl/server.key':
      ensure  => link,
      target  => "${cert_source_path}/privkey.pem",
      force   => true,
      require => Package[$package_name],
      notify  => Service[$service_name],
    }

    file { '/usr/local/openvpn_as/etc/web-ssl/ca.crt':
      ensure  => link,
      target  => "${cert_source_path}/fullchain.pem",
      force   => true,
      require => Package[$package_name],
      notify  => Service[$service_name],
    }
  }

  if $manage_service {
    service { $service_name:
      ensure => running,
      enable => true,
      require => Package[$package_name],
    }
  }

  # Apply config keys if provided
  if $config and !empty($config) {
    $config.each |$k, $v| {
      openvpnas::config::key { $k:
        key   => $k,
        value => $v,
      }
    }
  }
}


