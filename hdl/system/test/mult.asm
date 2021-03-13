MAIN:
load.l r7, 50
load.h r7, 0
load.l r1, 4
load.h r1, 0
load.l r2, 3
load.h r2, 0
sub.u r7, r7, 4
write.b r7, r1, 2
write.b r7, r2, 3
spc r3
add.u r3, r3, 8
write.w r7, r3
br $MULT
add.u r7, r7, 4
load.l r1, 0
load.h r1, 4
write.b r1, r0
MULT:
read.b r1, r7, 2
read.b r2, r7, 3
load.l r0, 0
load.h r0, 0
MULTLOOP:
cmp r3, r2, r0
br.az r3, $MULTEND
add.u r0, r0, r1
sub.u r2, r2, 1
br $MULTLOOP
MULTEND:
load.h r1, 0
read.b r1, r7
br r1
