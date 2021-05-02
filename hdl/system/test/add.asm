load.l r0, 1
load.h r0, 0
load.l r1, 2
load.h r1, 0
# uart-tx
load.l r3, 254
load.h r3, 127
add.u r2, r1, r0
write.b r3, r2
