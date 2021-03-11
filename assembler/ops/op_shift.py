from ops.op import op

class op_shift(op):
    
    MODE_LEFT  = 1
    MODE_RIGHT = 2

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_shift.MODE_LEFT:
            return "shiftl"
        else:
            return "shiftr"

    def invoke(self, params, labels, pos):
        instruction = 10 << op_shift.SHIFT_OPCODE

        if self.mode == op_shift.MODE_RIGHT:
            instruction |= 1 << op_shift.SHIFT_MODE

        instruction |= self.get_register(params, 0) << op_shift.SHIFT_RD \
            | self.get_register(params, 1) << op_shift.SHIFT_RA 

        if len(params) > 2:
            instruction |= self.get_immediate(params)

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[2]), 5)
