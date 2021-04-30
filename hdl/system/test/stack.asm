load.l r7, 0
load.h r7, 8 # SP
load.l r1, 1
load.h r1, 0
load.l r3, 0
load.h r3, 4 # UART
push r1
add.u r1, r1, 1
pop r1
write.b r3, r1
NOP:
add.u r1, r1, 0
br $NOP
