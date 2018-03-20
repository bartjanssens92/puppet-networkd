#
# Define networkd::network
#
define networkd::network(
  String            $iface               = $name,
  Array[String]     $address             = [],
  Array[String]     $dns                 = [],
  Array[String]     $domains             = [],
  Integer           $order               = 25,
  Optional[Boolean] $dhcp                = undef,
  Optional[Boolean] $linklocaladdressing = undef,
  Optional[Boolean] $llmnr               = undef,
  Optional[String]  $macaddress          = undef,
){
  include networkd

  concat { "networkd::network-${name}":
    ensure => present,
    path   => "/etc/systemd/network/${order}-${name}.network",
  }

  if $macaddress != undef {
    $match = [ "MACAddress=${macaddress}" ]
  } else {
    $match = [ "Name=${name}" ]
  }

  $values = [
    ['LinkLocalAddressing', $linklocaladdressing],
    ['LLMNR', $llmnr],
    ['DHCP', $dhcp],
    ['Domains', join($domains, ' ')],
    ['DNS', join($dns, ' ')],
    ['Address', join($address, ' ')],
  ].filter |$i| { ! empty($i[1]) }

  $network = $values.map |$i| { join($i,'=')}

  concat::fragment { "networkd::network-${name}.network":
    target  => "networkd::network-${name}",
    content => epp('networkd/inifile.epp',{data => [ ['Match', $match], ['Network', $network]]}),
    order   => '01'
  }
}
