load.l r0, 0
load.l r6, 0
load.l r1, 255
load.h r1, 127 # UART1-rx-ready
load.l r7, 254
load.h r7, 127 # UART1-data
load.l r4, 100
load.h r4, 0 # Start of application
UART_POLL:
read.b r2, r1
cmp r3, r2, r0
br.eq r3, $UART_POLL
UART_RECV:
read.b r2, r7
cmp r5, r6, r2
not r5, r5
br.eq r5, $CONTINUE
load.l r5, 255
load.h r5, 0
cmp r3, r5, r2
br.eq r3, $START
CONTINUE:
add.u r6, r2, 0
write.b r4, r2
add.u r4, r4, 1
br $UART_POLL
START:
cmp r0, r0, r0
load.l r4, 100
load.h r4, 0
br.az r0, r4
