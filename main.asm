.data
	dlg_plate_no: .asciiz "Plate Sensor Input: (max 8 characters)"
	dlg_route_detect: .asciiz "Route Detection:\n[ YES ] DROPOFF LANE\n[ NO ] PICKUP LANE"
	dlg_dropoff: .asciiz "A vehicle has dropped off the student(s). Student attendance has been updated."
	
	dlg_restart: .asciiz "Scanning for a new vehicle..."
	dlg_debug_continue: .asciiz "(Debug) Do you wish to continue?"
	
	dlg_pickup: .asciiz "A vehicle has arrived in the pickup lane. Is the student(s) for that vehicle ready?"
	dlg_pickup2: .asciiz "A vehicle is waiting in the waiting lane. Is the student(s) for that vehicle ready?"
	dlg_pickup_wait: .asciiz "Alert the vehicle to stay in the waiting lane. Waiting for the student(s) to be ready..."
	dlg_pickup_success: .asciiz "The vehicle has successfully pickup the student(s). Student waitlist has been updated."
	
	system_log1: .asciiz "LOG: A vehicle with plate no. of "
	system_log2: .asciiz " is arriving...\n"
	
	plate_no: .space 9			# Space reserved for 8 characters and 1 null-terminator

.text
main:
	j app_start				# Start the app with app_start
	
	app_restart:
		li $v0, 55			# Call MessageDialog function
		la $a0, dlg_restart		# Load sys_restart as the message
		li $a1, 2			# Set type of the message to 2 (warning)
		syscall				# Call syscall to initiate the function
	
	app_start:
		# Sensor1: Plate No Sensor
		li $v0, 54			# Call InputDialogString function
		la $a0, dlg_plate_no		# Load dlg_sens_plate as the message
		la $a1, plate_no		# Address of the input buffer
		li $a2, 9			# Maximum number of characters including null-terminator
		syscall
		
		# Actuator1: Plate No Validator
		# If the result is either CANCEL or INVALID data, assume there is no vehicle detected
		# and start scanning for a new vehicle (app_restart)
		bnez $a1, app_restart
		
		# Display the first part of the message
		li $v0, 4
		la $a0, system_log1
		syscall
		
		# Display plate no as the second part of the message
		li $v0, 4
		la $a0, plate_no
		syscall
		
		# Display the third part of the message
		li $v0, 4
		la $a0, system_log2
		syscall
		
		# Sensor2: Vehicle Routing Sensor
		li $v0, 50			# Call ConfirmDialog function
		la $a0, dlg_route_detect	# Load dlg_route_select as the message
		syscall
		
		# Actuator2: Vehicle Routing Actuator
		# If CANCEL is selected, assume the vehicle has no longer in the route
		# and start scanning for a new vehicle (app_restart)
		beq $a0, 2, app_restart
		
		# If YES is selected, jump to point_dropoff
		# otherwise, continue to point_pickup
		beqz $a0, point_dropoff
		
		la $s0, dlg_pickup		# Set $s0 to dlg_pickup to show the main message when called
		
		point_pickup:	
			# Sensor3: Student Checker
			li $v0, 50		# Call ConfirmDialog function
			la $a0, ($s0)		# Load $s0 as the message
			syscall
			
			# Actuator3: Vehicle Lane Selector
			# If CANCEL is selected, assume the vehicle has no longer in the route
			beq $a0, 2, app_restart
			
			# If NO is selected, send vehicle to waiting lane
			# else proceed as successful
			bnez $a0, point_pickup_wait
			
			li $v0, 55		# Call MessageDialog function
			la $a0, dlg_pickup_success
			syscall
			
			j app_debug_continue	# Jump to app_debug_continue
		
		point_pickup_wait:
			li $v0, 55		# Call MessageDialog function
			la $a0, dlg_pickup_wait	# Load dlg_pickup_wait as the message
			li $a1, 1		# Set the type of message to 1 (information)
			syscall
			
			la $s0, dlg_pickup2	# Set $s0 to dlg_pickup2 to show alt message when called
			
			j point_pickup		# Jump to point_pickup until the student(s) is ready
		
		point_dropoff:
			li $v0, 55		# Call MessageDialog function
			la $a0, dlg_dropoff	# Load dlg_dropoff as the message
			li $a1, 1		# Set the type of message to 1 (information)
			syscall
			
	app_debug_continue:
		li $v0, 50			# Call ConfirmDialog function
		la $a0, dlg_debug_continue	# Load dlg_debug_continue as the message
		syscall
		
		# If YES is selected, jump to app_restart
		# else proceed to app_exit
		beqz $a0, app_restart
		
	app_exit:
		li $v0, 10			# Call exit function
		syscall
