from ops.op import op

class op_branch(op):
    
    MODE_NONE = -1
    MODE_EQ   = 0
    MODE_GT   = 1
    MODE_LT   = 2
    MODE_AZ   = 3
    MODE_BZ   = 4

    def __init__(self, immediate, mode):
        self.immediate = immediate
        self.mode = mode

    def get_op(self):
        if self.immediate:
            return "br"
        else:
            if self.mode == op_branch.MODE_GT:
                return "br.gt"
            elif self.mode == op_branch.MODE_LT:
                return "br.lt"
            elif self.mode == op_branch.MODE_AZ:
                return "br.az"
            elif self.mode == op_branch.MODE_BZ:
                return "br.bz"
            elif self.mode == op_branch.MODE_EQ:
                return "br.eq"
            else:
                raise Exception("unknown branch mode")

    def invoke(self, params, labels, pos):
        instruction = 0
        
        # simple branch to a register or immediate offset
        if self.immediate:
            instruction = 11 << op_branch.SHIFT_OPCODE
            is_label = params[0][0] == '$'

            if not is_label:
                instruction |= 1 << op_branch.SHIFT_MODE \
                            | self.get_register(params, 0) << op_branch.SHIFT_RA
            else:
                instruction |= self.get_label_offset(params[0][1:], labels, pos, 8)
        # branch with compare code
        else:
            instruction = 12 << op_branch.SHIFT_OPCODE
            instruction |= self.mode << op_branch.SHIFT_RD
            instruction |= self.get_register(params, 0) << op_branch.SHIFT_RA
            is_label = params[1][0] == '$'
            if is_label:
                instruction |= 1 << op_branch.SHIFT_MODE
                instruction |= self.get_label_offset(params[1][1:], labels, pos, 5)
            else:
                instruction |= self.get_register(params, 1) << op_branch.SHIFT_RB

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])

    def get_label_offset(self, label, labels, pos, length):
        return self.two_complement(labels[label] - pos, length)
