# Coded by: Rafed Muhammad Yasir
# From github.com/rafed123

# Multiplying matrices
	xor $t1, $t1, $t1				# loop 1 var
L1:	
	slt $t0, $t1, $s0
	beq $t0, $zero, endL1

	xor $t2, $t2, $t2				# loop 2 var
	L2:
		slt $t0, $t2, $s0
		beq $t0, $zero, endL2
		
		mul $t4, $t1, $s0			# address of resultant[i][j]
		addu $t4, $t4, $t2
		sll $t4, $t4, 2
		addu $t4, $t4, $s3
		
		xor $t3, $t3, $t3			# loop 3 var
		L3:
			slt $t0, $t3, $s0
			beq $t0, $zero, endL3
			
			mul $t5, $t1, $s0		# address of matA[i][k]
			addu $t5, $t5, $t3
			sll $t5, $t5, 2
			addu $t5, $t5, $s1
			
			mul $t6, $t3, $s0		# address of matB[k][j]
			addu $t6, $t6, $t2
			sll $t6, $t6, 2
			addu $t6, $t6, $s2
			
			lw $t7, 0($t5)			# loading matA[i][k]
			lw $t8, 0($t6)			# loading matB[k][j]
			
			mul $t9, $t7, $t8		# matA[i][k] * matB[k][j]
			
			lw $t8, 0($t4)
			addu $t9, $t9, $t8		# resultant += matA[i][k] * matB[k][j]
			
			sw $t9, 0($t4)				
		
			addiu $t3, $t3, 1
			j L3
		endL3:
		
		addiu $t2, $t2, 1	
		j L2
	endL2:

	addiu $t1, $t1, 1
	j L1
endL1: