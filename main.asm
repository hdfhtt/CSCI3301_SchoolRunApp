.data
	app_title: .asciiz "SCHOOL RUN APP\n"
	vehicle_plate: .space 4
	
	text_arriving: .asciiz "Vehicle with plate ("
	text_arriving_e: .asciiz ") is arriving.\n"
	
	dialog_route: .asciiz "Is vehicle heading to the DROPOFF lane?"
	
.text 
main:
	AppStart:
	# Generate a 3-digit random plate number
	li $v0, 42
	li $a0, 100
	li $a1, 999
	syscall
	
	# Store generated plate number into data segment
	sw $a0, vehicle_plate
	
	li $v0, 4
	la $a0, app_title
	syscall
	
	# Vehicle Recognization:
	li $v0, 4
	la $a0, text_arriving
	syscall
	
	li $v0, 1
	lw $a0, vehicle_plate
	syscall
	
	li $v0, 4
	la $a0, text_arriving_e
	syscall
	
	# Route Detection:
	li $v0, 50
	la $a0, dialog_route
	syscall
	
	beq $a0, 2, AppStart
	
	AppExit:
	li $v0, 10
	syscall

# Helper Functions
concat_strings:
	# Initialize registers
	li $t0, 0			# Counter for first string
	li $t1, 0			# Counter for second string
	
	# Search the end of first string
	loop_1:
		lb $t2, ($a0)		# Load a byte from the first string
		beqz $t2, loop_2	# If the byte is zero (end of the string)
		addiu $a0, $a0, 1	# Increment the first string pointer
		addiu $t0, $t0, 1	# Increment the counter
		j loop_1
	
	# Search the end of second string
	loop_2:
		lb $t3, ($a1)		# Load a byte from the second string
		beqz $t3, loop_3
		addiu $a0, $a0, 1	# Increment the first string pointer
		addiu $a1, $a1, 1	# Increment the second string pointer
		addiu $t1, $t1, 1	# Increment the counter
		j loop_2
	
	# Copy the third string to the end of the concatenated string
	loop_3:
		lb $t4, ($a2)		# Load a byte from the third string
		beqz $t4, result
		sb $t4, ($a0)		# Store the byte at the end of the concatenated string
		addiu $a0, $a0, 1	# Increment the concatenated string pointer
		addiu $a2, $a2, 1	# Increment the third string pointer
		j loop_3
	
	# The result of concatenated string is in the memory address of the first string
	result:
		jr $ra