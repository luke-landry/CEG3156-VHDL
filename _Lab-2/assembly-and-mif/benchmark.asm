lw $2, 0; $t2 = memory(00) = 55
lw $3, 1; $t3 = memory(01) = AA
sub $1, $2, $3; $t1 = $t2- $t3 = 55
or $4, $1, $3; $t4 = $t1 or $t3 = FF
sw $4, 3; memory(03) = $t4 = FF
add $1, $2, $3; $t1 = $t2 + $t3 = FF
sw $1, 4; memory(04) = $t1 = FF
lw $2, 3; $t2 = memory(03) = FF
lw $3, 4; $t3 = memory(04) = FF
j 11; jump to address 44
beq $1, $1,-44; loop back to beginning of program
beq $1, $2,-8; test if $t1 = $t2 ?