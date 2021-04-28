from ops.op import op

class op_stack(op):
    
    MODE_PUSH_STACK       = 1
    MODE_PUSH_PC_TO_STACK = 2
    MODE_POP_STACK        = 3

    def __init__(self, mode):
        self.mode = mode

    def get_op(self):
        if self.mode == op_stack.MODE_PUSH_STACK:
            return "push"
        elif self.mode == op_stack.MODE_PUSH_PC_TO_STACK:
            return "push.pc"
        elif self.mode == op_stack.MODE_POP_STACK:
            return "pop"
        else:
             raise Exception("unknown spec mode")

    def invoke(self, params, labels, pos):
        instruction = 14 << op_stack.SHIFT_OPCODE
        
        if self.mode == op_stack.MODE_PUSH_STACK:
            instruction |= 7 << op_stack.SHIFT_RD
            instruction |= 7 << op_stack.SHIFT_RA
            instruction |= self.get_register(params, 0) << op_stack.SHIFT_RB

        elif self.mode == op_stack.MODE_PUSH_PC_TO_STACK:
            instruction |= 7 << op_stack.SHIFT_RD
            instruction |= 7 << op_stack.SHIFT_RA
            instruction |= 1
        elif self.mode == op_stack.MODE_POP_STACK:
            instruction |= self.get_register(params, 0) << op_stack.SHIFT_RD
            instruction |= 7 << op_stack.SHIFT_RA
            instruction |= 1 << op_stack.SHIFT_MODE

        return instruction

    def get_register(self, params, pos):
        return int(params[pos][1:])
