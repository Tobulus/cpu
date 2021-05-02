IRQ_VECTORS:
br $MAIN      # RST
br $UART_RECV # UART-IRQ
UART_RECV:
read.b r1, r3
reti
MAIN:
load.l r1, 0
load.h r1, 0
load.l r2, 0
load.h r2, 0
load.l r3, 254
load.h r3, 127 # UART
load.l r7, 0 
load.h r7, 127 # SP
ei
LOOP:
cmp r2, r1, r1
br.az r2, $LOOP
write.b r3, r1
br $LOOP
