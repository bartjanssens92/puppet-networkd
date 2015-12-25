define networkd::link(
  String  $macaddress = undef,
  Integer $order      = 25,
  Hash    $network    = undef,
) {
  include networkd

  $match = [
    "MACAddress=$macaddress",
  ]
  $link = [
    "Name=$name",
  ]

  file { "/etc/systemd/network/${order}-${name}.link":
    content => epp('networkd/inifile.epp',{data => [ ['Match', $match], ['Link', $link]]}),
  }

  if $network != undef {
    networkd::network{"$name":
      macaddress => $macaddress,
      *          => $network,
    }
  }
}
