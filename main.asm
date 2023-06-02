.data
	app_title: .asciiz "SCHOOL RUN APP\n"
	vehicle_plate: .space 4
	
	text_arriving: .asciiz "Vehicle with plate ("
	text_arriving_e: .asciiz ") is arriving.\n"
	
	dialog_route: .asciiz "Is vehicle heading to the DROPOFF lane?"
	
.text 
main:
	AppStart:
	# Generate a random plate number
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

	# TODO: HelperFunction