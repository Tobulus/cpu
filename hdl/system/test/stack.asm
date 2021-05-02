load.l r7, 0
load.h r7, 8 # SP
load.l r3, 0
load.h r3, 4 # UART
load.l r1, 1
load.h r1, 0
load.l r2, 5
load.h r2, 0
load.l r4, 8
load.h r4, 0
push r4
push r1
push r2
add.u r1, r1, 1
add.u r2, r2, 1
add.u r4, r4, 1
pop r2
pop r1
pop r4
write.b r3, r1
NOP:
add.u r1, r1, 0
br $NOP
