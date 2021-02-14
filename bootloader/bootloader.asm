load.l r0, 0
load.l r6, 0
load.l r1, 145
load.h r1, 1
load.l r7, 144
load.h r7, 1
load.l r8, 128
load.l r9, 144
load.h r9, 1
UART_POLL:
read.b r2, r1
cmp r3, r2, r0
bro.az r3, $UART_POLL
UART_RECV:
read.b r2, r7
cmp r5, r6, r2
not r5, r5
bro.eq r5, $CONTINUE
load.l r5, 255
cmp r3, r5, r2
bro.eq r3, $START
CONTINUE:
addi.u r6, r2, 0
write.b r9, r2
addi.u r9, r9, 1
bi $UART_POLL
START:
br.az r0, r8
