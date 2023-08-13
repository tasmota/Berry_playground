I would like to give credit to user 'sfromis', who was kind enough to write this code block and explain what it is doing, in order to help me solve a technical issue and better understand how Berry works.

# Multi-way Switching Logic

## What is Multi-way switching?
This short script allows relays (or lights) connected to an ESP32 running Tasmota to be "linked together" in order to create automated switching logic that operates 2 or more relays together in unison, essentially allowing you to use a bank of inexpensive SPDT relays as if they were DPDT relays.
Multi-way switching is useful for all kinds of electrical control scenarios where you would need to have multiple outputs activated simultaneously, or circuits activated in parallel, and need to assign the task to the micro-controller running Tasmota, rather than have external 3rd party automation software perform this task via mqtt. Having the micro-controller perform this switching task locally is faster and more reliable than having it performed externally by remote 3rd party automation software. 

### Potential uses
This script might conceivably be modified & built upon to create other types of switching logic such as:
  * Timer relays.
  * Following or cascading switching modes for multi-channel relay boards.
  * Multi-phase power switching.
  * Motor speed control.
  * H-Bridge control.
  * Multi-tap transformer control.
  * Controlling parallel circuits.


## What this Berry script does
Specifically, this script was written to control 5 relays, but it can be edited for other configurations.
  * What this script does is to monitor the power-states of relays 1 through 4, and if any of them are on, then relay 5 is also automatically turned on.
  * Likewise, if any of the relays 1 through 4 are turned off, then relay 5 is also turned off.
  * Also, if relays 1-4 are off, then relay 5 can not be turned on, if you try to turn it on while relays 1-4 are off, then it will immediately turn off.
  * Likewise, if relays 1-4 are on, thus relay 5 is on, then relay 5 can not be turned off. If you try to turn relay 5 off while relays 1-4 are on, it will immediately turn back on.

So the gist of it is:
```
  IF relays 1 through 4 = ON
    THEN relay 5 = ON
  ELSEIF relays 1 through 4 = OFF
    THEN relay 5 = OFF
```

## The Berry script
```javascript
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
```
### Here is a breakdown of what each line of code is doing:
1. First line defines a class, and last line instantiates the class to create an object.
2. The function of init() is initialization code for when the class is instantiated (creating an object).
3. The tasmota.add_driver allows the class instance to receive callbacks from Tasmota in many different situations.
4. set_power_handler() is just one of those, and it is only to be notified when a power status change happens.
5. tasmota.get_power() accesses a list of power states for all channels.
6. Index numbers in Berry starts with 0, and with 1 in Tasmota outside of Berry. Hence pow(2) matches Power3 etc.
7. tasmota.set_power() simply changes the state of one power channel.
8. Tricky thing is using the tasmota.set_timer(0, .... The reason is that the set_power_handler callback is not allowed to change any states, therefor the set_power call is deferred for 0 microseconds, meaning after exit from set_power_handler.

### Other notes
Berry code entered in the Berry REPL console is not saved anywhere, so to make this work permanently across reboots you will need to create a file autoexec.be with this Berry code to be loaded after boot. 

When you only enter code via the REPL console, the new code will in most cases supersede the old, but when using tasmota.add_driver the old iteration will persist. You can either reboot, build Tasmota with a development option providing a Berry restart button in the Berry REPL console, or you can change the init() method to:
```javascript
  def init()
    tasmota.remove_driver(global.MasterPower_instance)
    global.MasterPower_instance = self
    tasmota.add_driver(global.MasterPower_instance)
  end
```
This allows the driver to remove the old version of itself, and then register the new instance.

## Real-world use cases:
I have built a custom irrigation control box to control 4 irrigation zone valves for watering our garden and mini-orchard.
Relays 1-4 control the zone valves.
Relay 5 controls the 24 VAC transformer which energizes the zone valve solenoids.
Even when not under load, the 24 VAC transformer gets warm, and I want to keep that transformer powered off until it is actually needed in order to reduce heat buildup inside the control box and help protect the other components and extend their lifespan. Thus the need for the multi-way switching logic.
![IMG_20230805_110055HALF](https://github.com/LucidEye/Berry_playground/assets/12551280/2a1d3379-43db-416a-99d9-0c8b31c4c603)


Another scenario I might use this for in the future is controlling an evaporative cooler (swamp cooler).
Usually with a swamp cooler, you want to have a water pump activated in tandem with the blower fan.
This could also be coupled with the thermostat function available in Tasmota to create a "smart-thermostat" for a swamp cooler.
