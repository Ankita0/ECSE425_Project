and $2, $2, $0
or $3, $0, $0
Loop:
sll $5, $3, 2
addu $5, %5, $4
lw $5, 0($5)
add $2, $2, $5
addi $3, $3, 1
slti $5, $3, 100
bne $5, $0, Loop
