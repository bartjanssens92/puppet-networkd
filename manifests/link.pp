#
# This define allows for the creation of links and matching networks.
#
# @param macaddress
#    the macaddress of the interface
#
# @param order
#    the order of the link
#
# @param network
#    the network configuration that matches with this link
#
# @example
#    ```
#    ::networkd::link { 'ethusb0':
#      macaddress => '12:34:56:78:90:ab',
#      order      => '10',
#    }
#    ```
#    this piece of code would be used to
#    create the following link configuration:
#    ```
#    /etc/systemd/network/10-ethusb0.link
#
#    [Match]
#    MACAddress=12:34:56:78:90:ab
#
#    [Link]
#    Name=ethusb0
#    ```
define networkd::link(
  String  $macaddress = undef,
  Integer $order      = 25,
  Hash    $network    = undef,
) {
  include networkd

  $match = [
    "MACAddress=${macaddress}",
  ]
  $link = [
    "Name=${name}",
  ]

  file { "/etc/systemd/network/${order}-${name}.link":
    content => epp('networkd/inifile.epp',{data => [ ['Match', $match], ['Link', $link]]}),
  }

  if $network != undef {
    networkd::network{$name:
      macaddress => $macaddress,
      *          => $network,
    }
  }
}
