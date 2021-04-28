IRQ_VECTORS:
br $MAIN      # RST
br $UART_RECV # UART-IRQ
UART_RECV:
load.l r3, 0
load.h r3, 4
read.b r4, r3
write.b r3, r4
reti
MAIN:
load.l r7, 0 
load.h r7, 4 # SP
ei
LOOP:
add.u r1, r1, 0 # NOP
br $LOOP
