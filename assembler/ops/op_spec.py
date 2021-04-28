from ops.op import op

class op_spec(op):
    
    MODE_EI   = 1
    MODE_DI   = 2
    MODE_RETI = 3
    MODE_SPC  = 4

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_spec.MODE_RETI:
            return "reti"
        elif self.mode == op_spec.MODE_EI:
            return "ei"
        elif self.mode == op_spec.MODE_DI:
            return "di"
        elif self.mode == op_spec.MODE_SPC:
            return "spc"
        else:
             raise Exception("unknown spec mode")

    def invoke(self, params, labels, pos):
        instruction = 13 << op_spec.SHIFT_OPCODE
        
        if self.mode == op_spec.MODE_RETI:
            instruction |= 4
            instruction |= 7 << op_spec.SHIFT_RA
        elif self.mode == op_spec.MODE_EI:
            instruction |= 1
        elif self.mode == op_spec.MODE_DI:
            instruction |= 2
        elif self.mode == op_spec.MODE_SPC:
            instruction |= self.get_register(params, 0) << op_spec.SHIFT_RD

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])
