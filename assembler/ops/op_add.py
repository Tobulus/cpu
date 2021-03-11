from ops.op import op

class op_add(op):
    
    SHIFT_IMMEDIATE = 1

    def __init__(self, signed):
        self.signed = signed

    def get_op(self):
        if self.signed:
            return "add.s"
        else:
            return "add.u"

    def invoke(self, params, labels, pos):
        instruction = 0
        is_immediate = False

        try:
            int(params[2])
            is_immediate = True
        except:
            pass

        if not self.signed:
            instruction |= 1 << op_add.SHIFT_MODE

        if is_immediate:
            instruction |= self.get_register(params, 0) << op_add.SHIFT_RD \
                    | self.get_register(params, 1) << op_add.SHIFT_RA \
                    | self.get_immediate(params) << op_add.SHIFT_IMMEDIATE \
                    | 1
        else:
            instruction |= self.get_register(params, 0) << op_add.SHIFT_RD \
                    | self.get_register(params, 1) << op_add.SHIFT_RA \
                    | self.get_register(params, 2) << op_add.SHIFT_RB

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_immediate(self, params):
        return self.two_complement(int(params[2]), 4)
