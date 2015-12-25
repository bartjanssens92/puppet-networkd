define networkd::netdev::macvlan(
  String  $interface,
  String  $mode       = "bridge",
  Integer $order      = 25,
  Hash    $network    = undef,
) {
  include networkd

  $data = [
    ["NetDev", [
      "Name=${name}",
      "Kind=macvlan",
    ],],
    ["MACVLAN", [
      "mode=$mode"
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

  concat::fragment { "networkd::network-${interface}.macvlan-${name}":
    target  => "networkd::network-${interface}",
    content => "MACVLAN=${name}\n",
    order   => '10'
  }
}
