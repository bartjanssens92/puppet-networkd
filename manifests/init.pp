class networkd {
  service { "systemd-networkd":
    ensure  => "running",
    enable  => "true",
  }

  stage { 'network':
    before => Stage['main'],
  }
  Networkd::Network {
    stage => 'network'
  }
  file { '/etc/systemd/network':
    ensure => directory,		# make sure this is a directory
    recurse => true,		# recursively manage directory
    purge => true,
    force => true,
    notify => Service["systemd-networkd"],
  }
}
