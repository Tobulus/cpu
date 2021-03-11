from ops.op import op

class op_mem_write(op):
    
    MODE_WORD = 1
    MODE_BYTE = 2

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_mem_write.MODE_WORD:
            return "write.w"
        else:
            return "write.b"

    def invoke(self, params, labels, pos):
        instruction = 7 << op_mem_write.SHIFT_OPCODE

        if self.mode == op_mem_write.MODE_WORD:
            instruction |= 1 << op_mem_write.SHIFT_MODE

        instruction |= self.get_register(params, 0) << op_mem_write.SHIFT_RA \
            | self.get_register(params, 1) << op_mem_write.SHIFT_RB 

        if len(params) > 2:
            immediate = self.get_immediate(params)
            instruction |= (immediate & 28) << op_mem_write.SHIFT_RD
            instruction |= (immediate & 3)

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[2]), 5)
