from ops.op import op

class op_mem_read(op):
    
    MODE_WORD = 1
    MODE_BYTE = 2

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_mem_read.MODE_WORD:
            return "read.w"
        else:
            return "read.b"

    def invoke(self, params, labels, pos):
        instruction = 6 << op_mem_read.SHIFT_OPCODE

        if self.mode == op_mem_read.MODE_WORD:
            instruction |= 1 << op_mem_read.SHIFT_MODE

        instruction |= self.get_register(params, 0) << op_mem_read.SHIFT_RD \
            | self.get_register(params, 1) << op_mem_read.SHIFT_RA 

        if len(params) > 2:
            instruction |= self.get_immediate(params)

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[2]), 5)
