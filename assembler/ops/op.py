class op:

    SHIFT_OPCODE = 12
    SHIFT_RD     = 9
    SHIFT_MODE   = 8
    SHIFT_RA     = 5
    SHIFT_RB     = 2

    def two_complement(self, n, bits):
        return n & int(bin((1<<bits)-1),2)
