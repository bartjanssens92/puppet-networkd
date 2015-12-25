define networkd::network(
  String $iface=$name,
  Array[String]     $address    = [],
  Optional[String]  $macaddress = undef,
  Integer           $order      = 25,
  Optional[Boolean] $linklocaladdressing = undef,
  Optional[Boolean] $llmnr = undef,
  Optional[Boolean] $dhcp = undef,
  Array[String]     $domains    = [],
  Array[String]     $dns        = [],
){
  include networkd

  concat { "networkd::network-${name}":
    path   => "/etc/systemd/network/${order}-${name}.network",
    ensure => present,
  }

  if $macaddress != undef {
    $match = [ "MACAddress=$macaddress" ]
  } else {
    $match = [ "Name=$name" ]
  }

  $values = [
    ["LinkLocalAddressing", "$linklocaladdressing"],
    ["LLMNR", "$llmnr"],
    ["DHCP", "$dhcp"],
    ["Domains", join($domains, " ")],
    ["DNS", join($dns, " ")],
    ["Address", join($address, " ")],
  ].filter |$i| { ! empty($i[1]) }

  $network = $values.map |$i| { join($i,"=")}

  concat::fragment { "networkd::network-${name}.network":
    target  => "networkd::network-${name}",
    content => epp('networkd/inifile.epp',{data => [ ['Match', $match], ['Network', $network]]}),
    order   => '01'
  }


}
