from ops.op import op

class op_and(op):
    
    def get_op(self):
        return "and"

    def invoke(self, params, labels, pos):
        instruction = 3 << op_and.SHIFT_OPCODE
        is_immediate = False

        try:
            int(params[2])
            is_immediate = True
        except:
            pass

        if is_immediate:
            instruction |= 1 << op_and.SHIFT_MODE \
                    | self.get_register(params, 0) << op_and.SHIFT_RD \
                    | self.get_register(params, 1) << op_and.SHIFT_RA \
                    | self.get_immediate(params)
        else:
            instruction |= self.get_register(params, 0) << op_and.SHIFT_RD \
                    | self.get_register(params, 1) << op_and.SHIFT_RA \
                    | self.get_register(params, 2) << op_and.SHIFT_RB

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[2]), 5)
