define networkd::netdev::vlan(
  String  $interface,
  Integer $id,
  Integer $order      = 25,
  Hash    $network    = undef,
) {
  include networkd

  $data = [
    ["NetDev", [
      "Name=${name}",
      "Kind=vlan",
    ],],
    ["VLAN", [
      "Id=$id"
    ]]
  ]

  file { "/etc/systemd/network/${order}-${name}.netdev":
    content => epp('networkd/inifile.epp',{data => $data}),
  }

  if $network != undef {
    networkd::network{"$name":
      *          => $network,
    }
  }

  concat::fragment { "networkd::network-${interface}.vlan-${name}":
    target  => "networkd::network-${interface}",
    content => "VLAN=${name}\n",
    order   => '10'
  }
}
