# @summary Import bulk OpenVPN AS configuration from a JSON file via sacli
#
# @param source
#   Puppet file source or content path to JSON configuration to import.
# @param refresh_on_change
#   Whether to restart/apply after import.
define openvpnas::config::import (
  String[1] $source,
  Boolean $refresh_on_change = true,
) {
  $staging_path = '/usr/local/openvpn_as/etc/tmp-import.json'

  file { $staging_path:
    ensure => file,
    mode   => '0640',
    owner  => 'root',
    group  => 'root',
    source => $source,
  }

  exec { 'openvpnas-config-import':
    path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
    command     => "/usr/local/openvpn_as/scripts/sacli -v \"$(cat ${staging_path})\" ConfigReplace",
    refreshonly => true,
    subscribe   => File[$staging_path],
  }

  if $refresh_on_change {
    exec { 'openvpnas-config-apply':
      path        => ['/bin', '/usr/bin', '/sbin', '/usr/sbin'],
      command     => '/usr/local/openvpn_as/scripts/sacli start',
      refreshonly => true,
      subscribe   => Exec['openvpnas-config-import'],
    }
  }
}
