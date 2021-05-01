# Assembler

## Addition
### Signed
```
add.s r3, r2, r2
add.s r2, r1, 1
```
### Unsigned
```
add.u r3, r2, r2
add.u r2, r1, 1
```
## Subtraction
### Signed
```
sub.s r3, r2, r2
sub.s r2, r1, 1
```
### Unsigned
```
sub.u r3, r2, r2
sub.u r2, r1, 1
```
## OR
```
or r3, r2, r1
or r3, r2, 2
```
## AND
```
and r3, r2, r1
and r3, r2, 2
```
## XOR
```
xor r3, r2, r1
xor r3, r2, 2
```
## NOT
```
not r2, r1
```
## Memory
### Memory read
```
read.b r2, r1    # read one byte from adress in r1 into r2
read.b r2, r1, 2 # read one byte from adress in r1 + 2 into r2
read.w r2, r1    # read two byte from adress in r1 into r2
read.w r2, r1, 2 # read two byte from adress in r1 + 2 into r2
```
### Memory write
```
write.b r2, r1    # write one byte from r1 to the adress stored in r2
write.b r2, r1, 2 # write one byte from r1 to the adress stored in r2 + 2
write.w r2, r1    # write two byte from r1 to the adress stored in r2
write.w r2, r1, 2 # write one byte from r1 to the adress stored in r2 + 2
```
## LOAD
```
load.l r1, 2 # load the value 2 into the low byte of r1
load.h r1, 1 # load the value 1 into the high byte of r1
```
## Compare
```
cmp r3, r2, r1 # compare the values in r2 and r1 and store the compare result in r3
```

## Shift
```
shiftl r2, r1 
shiftl r2, r1 , 2
shiftr r2, r1 
shiftr r2, r1 , 2
```
## Label
```
$LABEL:
```

## Branch
```
br $LABEL
br r1
br.eq r1, $LABEL
br.eq r1, r2
br.lt r1, $LABEL
br.lt r1, r2
br.gt r1, $LABEL
br.gt r1, r2
br.az r1, $LABEL
br.az r1, r2
br.bz r1, $LABEL
br.bz r1, r2
```

## Save program counter
```
spc r1
```
## Stack operations
```
push r1
pop r1
```
## Interrupts
```
ei   # enable interrupts
di   # disable interrupts
reti # return from an interrup handler
```
