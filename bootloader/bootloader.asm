load r0, 0
load r6, 0
load r1, ADDR_UART_RX_DATA_READY
load r7, ADDR_UART_RX_DATA
load r8, ADDR_FIRMWARE
load r9, ADDR_WRITE_BYTE
UART_POLL:
read.b r2, r1
cmp r3, r2, r0
bro.az r3, $UART_POLL
UART_RECV:
read.b r2, r7
cmp r5, r6, r2
and.i r3, r2, 255
cmp r3, r3  
add.i r6, r2, 0
write.b r9, r2
add.i r9, r9, 1
bi $UART_POLL
START:
bi $ADDR_FIRMWARE
