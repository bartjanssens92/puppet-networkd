#
# Class networkd
#
# This class manages the service and configuration of systemd-networkd.
#
# @example Start managing systemd-networkd
#   include ::networkd
#
class networkd (
  Boolean $purge = true,
) {
  service { 'systemd-networkd':
    ensure => 'running',
    enable => true,
  }

  stage { 'network':
    before => Stage['main'],
  }
  Networkd::Network {
    stage => 'network'
  }

  file { '/etc/systemd/network':
    ensure  => directory,
    recurse => true,
    purge   => $purge,
    force   => true,
    notify  => Service['systemd-networkd'],
  }
}
