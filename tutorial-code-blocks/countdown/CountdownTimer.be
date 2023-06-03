# Countdown timer
# Decrements a number each second
# Example of:
# - Adding a command
# - Using a closure 
# - Create a timer for a delay

def countdown(cmd, idx, payload, payload_json)
	var count = 0
	
	# define a closure function to call from the timer
	# Note it can access the local variable count in the wrapper function
	def deccounter()
		count = count - 1
		print(count)
		if count > 0
			# Create a timer for 1 second in the future to call the closure deccounter
			tasmota.set_timer(1000,deccounter,"deccounter")
		end
	end
	if payload != ""
		count = int(payload)
		deccounter()
	end
	tasmota.resp_cmnd_done() # This is to signal a successful command
end

tasmota.add_cmd('countdown', countdown)
