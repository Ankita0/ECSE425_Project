				addi $11,  $0, 2000  	# initializing the beginning of Data Section address in memory
				addi $15, $0, 4 		# word size in byte
Bitwise:        addi $1, $0, 3
                addi $2, $0, 4
                and  $3, $1, $2         # z = x & y
				addi $10, $0, 0
				mult $10, $15			# $lo=4*$10, for word alignment 
				mflo $12				# assume small numbers
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
				add $2,$0,$3 
				sw	 $2, 0($13)
                beq  $1, $0, False      # branch to False if x = 0
                beq  $2, $0, False      # branch to False if y = 0
                addi $4, $0, 1          # x and y are both nonzero, so w = 1
				addi $10, $0, 1
				mult $10, $15			# $lo=4*$10, for word alignment 
				mflo $12				# assume small numbers
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
				add $2,$0,$4 
				sw	 $2, 0($13)
                j Continue
False:          addi $4, $0, 0          # x and/or y are 0, so w = 0
Continue:       or   $5, $1, $2         # a = x | y
				addi $10, $0, 3
				mult $10, $15			# $lo=4*$10, for word alignment 
				mflo $12				# assume small numbers
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
				add $2,$0,$5 
				sw	 $2, 0($13)
                bne  $1, $0, True       # branch to True if x is non-zero
                bne  $2, $0, True       # branch to True if y is non-zero
                addi $6, $0, 0          # x and y are both zero, so b = 0
				addi $10, $0, 4
				mult $10, $15			# $lo=4*$10, for word alignment 
				mflo $12				# assume small numbers
				add  $13, $11, $12 		# Make data pointer [2000+($10)*4]
				add $2,$0,$6 
				sw	 $2, 0($13)
                j End
True:           addi $6, $0, 1          # x and/or y are non-zero, so b = 1
End:       		beq	 $11, $11, End 		#end of program (infinite loop)
