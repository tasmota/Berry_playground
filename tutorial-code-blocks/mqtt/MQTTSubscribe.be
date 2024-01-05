# MQTT Communications

# The following example shows how to subscribe to a specific MQTT topic
# and how to process a received message

# some modules are required
import string
import mqtt

# This function processes received MQTT messages
def mqtt_handler(topic, idx, payload_s, payload_b)

	print("got mqtt-message with topic:",topic," and payload:",payload_s)

end

# Always unsubscribe to the topic first. It's not a problem if there was no subscription beforehand.
mqtt.unsubscribe("cmnd/mqttmsg/control")
 
# - subscribe for the topic 'cmnd/mqttmsg/control' 
# - the message should be processed by the function 'mqtt_handler'
# - don't worry about the MQTT connection, the MQTT driver is smart enough 
#   to handle all connect/disconnect scenarios
mqtt.subscribe("cmnd/mqttmsg/control",mqtt_handler)

# to test: 
#      - use an MQTT-client.application like 'MQTT Explorer' and publish any value to the cmnd/mqttmsg/control topic.
#      - observe the output in the Berry Scripting console