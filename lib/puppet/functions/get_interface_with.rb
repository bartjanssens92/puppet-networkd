Puppet::Functions.create_function(:get_interface_with) do
  def get_interface_with(tests)
    interfaces = closure_scope.lookupvar('networking')['interfaces']

    interfaces.each do |ifname, info|
      (info.fetch('bindings',[]) + info.fetch('bindings6',[])).each do | binding |
        good = true
        tests.each do |kind, value|
          unless lookupval(info, binding, kind) == value
            good = false
            break
          end
        end
        if good
          info = info.dup
          info['name'] = ifname
          return info
        end
      end
    end
    return nil
  end
  def lookupval(info, binding, kind)
    if kind == "macaddress" || kind == "mac"
      return info["mac"]
    end
    return binding[kind]
  end
end
