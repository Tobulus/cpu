IRQ_VECTORS:
br $MAIN      # RST
br $UART_RECV # UART-IRQ
br $TIMER1    # TIMER1-IRQ
UART_RECV:
reti
TIMER1:
add.u r1, r1, 1
reti
MAIN:
load.l r1, 0
load.h r1, 0
load.l r2, 0
load.h r2, 0
# UART
load.l r3, 254
load.h r3, 127
# SP
load.l r7, 0 
load.h r7, 127
# init TIMER1 count
load.l r4, 246
load.h r4, 127
load.l r6, 0
load.h r6, 16 # every 1000 ticks
write.b r4, r6
# enable timer1
load.l r4, 247
load.h r4, 127
load.l r6, 1
load.h r6, 0
write.b r4, r6
# enable interrupts
ei
LOOP:
cmp r2, r1, r1
br.az r2, $LOOP
write.b r3, r1
br $LOOP
