load.l r0, 0
load.l r6, 0
load.l r1, 1
load.h r1, 4
load.l r7, 0
load.h r7, 4
load.l r4, 100
load.h r4, 0
UART_POLL:
read.b r2, r1
cmp r3, r2, r0
bro.eq r3, $UART_POLL
UART_RECV:
read.b r2, r7
cmp r5, r6, r2
not r5, r5
bro.eq r5, $CONTINUE
load.l r5, 255
load.h r5, 0
cmp r3, r5, r2
bro.eq r3, $START
CONTINUE:
addi.u r6, r2, 0
write.b r4, r2
addi.u r4, r4, 1
bi $UART_POLL
START:
br.az r0, r4
