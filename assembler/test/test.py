import os

def next(f):
    a = int.from_bytes(f.read(2), 'little')
    print (a)
    return a

os.system('python3.8 ../assembler.py --input test.asm --output test_run')

with open('test_run', 'rb') as f:
    #add
    assert next(f) == int('0b0000011101000100', 2)
    assert next(f) == int('0b0000011001000100', 2)
    assert next(f) == int('0b0000011101000011', 2)
    assert next(f) == int('0b0000011001011111', 2)
    #sub
    assert next(f) == int('0b0001011101000100', 2)
    assert next(f) == int('0b0001011001000100', 2)
    assert next(f) == int('0b0001011101000011', 2)
    assert next(f) == int('0b0001011001011111', 2)
    #or
    assert next(f) == int('0b0010011001000100', 2)
    assert next(f) == int('0b0010010100100001', 2)
    #and
    assert next(f) == int('0b0011011001000100', 2)
    assert next(f) == int('0b0011010100100001', 2)
    #xor
    assert next(f) == int('0b0100011001000100', 2)
    assert next(f) == int('0b0100010100100001', 2)
    #not
    assert next(f) == int('0b0101010000100000', 2)
    #mem read
    assert next(f) == int('0b0110010100100000', 2)
    assert next(f) == int('0b0110010100100001', 2)
    assert next(f) == int('0b0110010000100000', 2)
    assert next(f) == int('0b0110010000100001', 2)
    #mem write
    assert next(f) == int('0b0111000101000100', 2)
    assert next(f) == int('0b0111000101000101', 2)
    assert next(f) == int('0b0111000001000100', 2)
    assert next(f) == int('0b0111000001000101', 2)
    #load
    assert next(f) == int('0b1000001000000001', 2)
    assert next(f) == int('0b1000001100000001', 2)
    #cmp
    assert next(f) == int('0b1001011001000100', 2)
    #shift
    assert next(f) == int('0b1010010000100001', 2)
    assert next(f) == int('0b1010010100100001', 2)
    #branch
    assert next(f) == int('0b1011000000000010', 2)
    assert next(f) == int('0b1100000001000100', 2)
    assert next(f) == int('0b1100001000000001', 2)
print("Success!")

os.system('rm test_run')
