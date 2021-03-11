from ops.op import op

class op_cmp(op):
    
    def get_op(self):
        return "cmp"

    def invoke(self, params, labels, pos):
        instruction = 9 << op_cmp.SHIFT_OPCODE

        instruction |= self.get_register(params, 0) << op_cmp.SHIFT_RD \
                    | self.get_register(params, 1) << op_cmp.SHIFT_RA \
                    | self.get_register(params, 2) << op_cmp.SHIFT_RB
        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])
