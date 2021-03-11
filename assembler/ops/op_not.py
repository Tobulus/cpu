from ops.op import op

class op_not(op):
    
    def get_op(self):
        return "not"

    def invoke(self, params, labels, pos):
        instruction = 5 << op_not.SHIFT_OPCODE

        instruction |= self.get_register(params, 0) << op_not.SHIFT_RD \
                    | self.get_register(params, 1) << op_not.SHIFT_RA
        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])
