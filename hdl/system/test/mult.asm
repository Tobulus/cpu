MAIN:
load.l r8, 128
load.l r1, 4
load.l r2, 3
subi.u r8, r8, 4
write.b r8, r1, 2
write.b r8, r2, 3
spc r3
addi.u r3, r3, 8
write.w r8, r3
bi $MULT
subi.u r8, r8, 4
load.l r1, 144
load.h r1, 1
write.b r1, r0
NOP:
addi.u r2, r2, 0
bi $NOP
MULT:
read.b r1, r8, 2
read.b r2, r8, 3
load.l r0, 0
MULTLOOP:
cmp r3, r2, r0
bro.az r3, $MULTEND
add.u r0, r0, r1
subi.u r2, r2, 1
bi $MULTLOOP
MULTEND:
br r8
