# MQTT Communications


import json
import string
import mqtt

def mqtt_msg(topic, idx, payload_s, payload_b)
	
	var msg = json.load(payload_s)
	print(msg)
end

def subscribes()
  mqtt.subscribe("cmnd/mqttmsg/control",mqtt_msg)
end

tasmota.add_rule("MQTT#Connected=1", subscribes)
