.data
	temp_concat: .space 64
	temp_plate_no: .space 8
	
	str_arriving1: .asciiz "A vehicle with plate no. of "
	str_arriving2: .asciiz " is heading to the PICKUP point..."
	str_arriving3: .asciiz " is heading to the DROPOFF point..."

	str_plate_sensor: .asciiz "Plate Sensor Input:"
	str_restart: .asciiz "Scanning for a new vehicle..."
	
	str_route_select: .asciiz "Is vehicle heading to DROPOFF lane?"
	
.text
main:
	j app_start
	
	app_restart:
		li $v0, 55			# Call MessageDialog function
		la $a0, str_restart		# Load str_restart as the message
		syscall
	
	app_start:
		# Sensor1: Plate No Sensor
		li $v0, 54			# Call InputDialogString function
		la $a0, str_plate_sensor
		la $a1, temp_plate_no		# Address of the input
		li $a2, 8			# Maximum number of characters to read
		syscall
		
		bnez $a1, app_restart
		
		# Sensor2: Route Detection
		li $v0, 50			# Call ConfirmDialog function
		la $a0, str_route_select	# Load str_route_select as the message
		syscall
		
		# Actuator1: Route Detection Display
		move $s1, $a0			# Move result of syscall 50 in $a0 to $s1
		la $a0, str_arriving1		# Load str_arriving1
		la $a1, temp_plate_no		# Load plate number
		beq $s1, 2, app_restart		# If CANCEL is selected, jump to app_restart
		beqz $s1, point_dropoff		# If YES is selected, jump to point_dropoff
		
		point_pickup: 
			la $a2, str_arriving2	# Load str_arriving2 (pickup)
			j point_actuator
			
		point_dropoff: 
			la $a2, str_arriving3 	# Load str_arriving3 (dropoff)
			
		point_actuator:
			la $a3, temp_concat
			jal concat_strings	# Call the concat_strings function
			
		li $v0, 55			# Call MessageDialog function
		la $a0, temp_concat		# Load saved concatenated strings as the message
		syscall

	# Terminate the program
	li $v0, 10
	syscall

# Helper functions
# concat_strings(str1, str2, str3, return)
concat_strings:
	move $t0, $a0				# Save the address of str1
	move $t1, $a3				# Save the address of result

	# Copy str1 to result
	cs_loop1:
		lb $t2, ($t0)			# Load a character from str1
		sb $t2, ($t1)			# Store the character in result

		beqz $t2, cs_loop2		# If the character is null, proceed to loop2
		addiu $t0, $t0, 1		# Increment str1 pointer
		addiu $t1, $t1, 1		# Increment result pointer
		j cs_loop1			# Repeat for the next character

	# Copy str2 to result
	cs_loop2:
		lb $t2, ($a1)			# Load a character from str2
		sb $t2, ($t1)			# Store the character in result

		beqz $t2, cs_loop3		# If the character is null, proceed to loop3
		addiu $a1, $a1, 1		# Increment str2 pointer
		addiu $t1, $t1, 1		# Increment result pointer
		j cs_loop2			# Repeat for the next character

	# Copy str3 to result
	cs_loop3:
		lb $t2, ($a2)			# Load a character from str3
		sb $t2, ($t1)			# Store the character in result

		beqz $t2, cs_end		# If the character is null, we're done
		addiu $a2, $a2, 1		# Increment str3 pointer
		addiu $t1, $t1, 1		# Increment result pointer
		j cs_loop3			# Repeat for the next character

	cs_end:
		jr $ra
