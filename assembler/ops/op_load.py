from ops.op import op

class op_load(op):
    
    MODE_HIGH = 1
    MODE_LOW = 2

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_load.MODE_HIGH:
            return "load.h"
        else:
            return "load.l"

    def invoke(self, params, labels, pos):
        instruction = 8 << op_load.SHIFT_OPCODE

        if self.mode == op_load.MODE_HIGH:
            instruction |= 1 << op_load.SHIFT_MODE

        instruction |= self.get_register(params, 0) << op_load.SHIFT_RD \
            | self.get_immediate(params)

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[1]), 8)
