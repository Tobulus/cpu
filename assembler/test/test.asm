add.u r3, r2, r1
add.s r3, r2, r1
addi.u r3, r2, 1
addi.s r3, r2, -1
sub.u r3, r2, r1
sub.s r3, r2, r1
subi.u r3, r2, 1
subi.s r3, r2, -1
or r3, r2, r1
or r2, r1, 1
and r3, r2, r1
and r2, r1, 1
xor r3, r2, r1
xor r2, r1, 1
not r2, r1
read.w r2, r1, 0
read.w r2, r1, 1
read.b r2, r1, 0
read.b r2, r1, 1
write.w r2, r1, 0
write.w r2, r1, 1
write.b r2, r1, 0
write.b r2, r1, 1
load.l r1, 1
load.h r1, 1
cmp r3, r2, r1
shiftl r2, r1, 1
TEST:
shiftr r2, r1, 1
bi $TEST
br.eq r2, r1
bro.gt r1, $TEST
