#
# This define allows for the creation of network files.
#
# @param iface
#    the name of the interface, default to namevar
#
# @param address
#    the ip address to assign to the interface, can be
#    multiples by specifying more in the array
#
# @param dhcp
#    what setting for dhcp to use
#
# @param dns
#    what dns to use
#
# @param domains
#    which domain to use, can multiples
#
# @param linklocaladdressing
#    enable / disable linklocaladdressing
#
# @param llmnr
#    enable / disable llmnr
#
# @param macaddress
#    the macaddress of the interface
#
# @param order
#    the order of the interface
#
# @example
#    ```
#    ::networkd::network { 'enp0s31f6':
#      dns                 => ['8.8.8.8'],
#      address             => ['192.168.10.199'],
#      gateway             => '192.168.10.1',
#      linklocaladdressing => true,
#    ```
#    this would render the following network file
#    ```
#    /etc/systemd/network/99-enp.network
#
#    [Match]
#    Name=enp0s31f6
#
#    [Network]
#    DNS=8.8.8.8
#    Address=192.168.10.199
#    Gateway=192.168.10.1
#    LinkLocalAddressing=yes
#    ```
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
  Optional[String]  $gateway             = undef,
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
    ['Gateway', String($gateway)],
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
