class MasterPower
    def init()
      tasmota.add_driver(self)
    end
    def set_power_handler(cmd, idx)
      var pow = tasmota.get_power()
      var anypower = pow[0] || pow[1] || pow[2] || pow[3]
      if anypower != pow[4]
        tasmota.set_timer(0, /-> tasmota.set_power(4, anypower))
      end
    end
  end
  MasterPower()