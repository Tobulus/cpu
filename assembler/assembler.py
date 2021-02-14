import re, sys
from optparse import OptionParser

LABEL   = "(\w+):"
ADD     = "add.(u|s) r(\d), r(\d), r(\d)"
ADDI    = "addi.(u|s) r(\d), r(\d), (-?\d{1,3})"
SUB     = "sub.(u|s) r(\d), r(\d), r(\d)"
SUBI    = "subi.(u|s) r(\d), r(\d), (-?\d{1,3})"
NOT     = "not r(\d), r(\d)"
OR      = "or r(\d), r(\d), ((r(\d))|(-?\d{1,3}))"
AND     = "and r(\d), r(\d), ((r(\d))|(-?\d{1,3}))"
XOR     = "xor r(\d), r(\d), ((r(\d))|(-?\d{1,3}))"
READW   = "read.w r(\d), r(\d)(, (-?\d{1,3}))?"
READB   = "read.b r(\d), r(\d)(, (-?\d{1,3}))?"
WRITEW  = "write.w r(\d), r(\d)(, (-?\d{1,3}))?" 
WRITEB  = "write.b r(\d), r(\d)(, (-?\d{1,3}))?" 
LOAD    = "load.(l|h) r(\d), (-?\d{1,3})"
CMP     = "cmp r(\d), r(\d), r(\d)"
SHIFTL  = "shiftl r(\d), r(\d)(, (\d{1,3}))?"
SHIFTR  = "shiftr r(\d), r(\d)(, (\d{1,3}))?"
BI      = "bi \$(\w+)"
BR      = "br.(gt|lt|az|bz|eq) r(\d), r(\d)"
BRO     = "bro.(gt|lt|az|bz|eq) r(\d), \$(\w+)"
SPC     = "spc r(\d)"

SHIFT_OPCODE            = 12
SHIFT_RD                = 9
SHIFT_MODE              = 8
SHIFT_RA                = 5
SHIFT_RB                = 2
SHIFT_IMMEDIATE_ADD_SUB = 1
CMP_EQ = 0
CMP_RA_GT_RB = 1
CMP_RB_GT_RA = 2
CMP_RA_ZERO = 3
CMP_RB_ZERO = 4

optparser = OptionParser()
optparser.add_option("--ascii", action="store_true", dest="ascii")
optparser.add_option("--input", action="store", type="string", dest="input_file")
optparser.add_option("--output", action="store", type="string", dest="output_file")
(options, args) = optparser.parse_args(sys.argv)

output = []

def two_complement(n, bits):
    return n & int(bin((1 << (bits)) - 1), 2)

with open(options.input_file) as f:
    pos = 0
    labels = {}
    lines = [line[:-1] for line in f.readlines()]

    # parse all labels first to get their memory offsets
    for line in lines:
        if match := re.fullmatch(LABEL, line):
            if match.group(1) in labels:
                raise Exception('Label "{}" already exists'.format(match.group(1)))
            labels[match.group(1)] = pos
        else:
            pos += 2
    print(labels)
    # parse instructions
    pos = 0
    for line in lines:
        instruction = 0

        if match := re.fullmatch(ADD, line):
            print("{}: add".format(line))
            instruction = int(match.group(2)) << SHIFT_RD \
                    | int(match.group(3)) << SHIFT_RA \
                    | int(match.group(4)) << SHIFT_RB
            if match.group(1) == 'u':
                instruction |= 1 << SHIFT_MODE
            elif match.group(1) == 's':
                pass
            else:
                raise Exception('Mode "{}" does not exist'.format(match.group(1)))
            output.append(instruction)

        elif match := re.fullmatch(SUB, line):
            print("{}: sub".format(line))
            instruction = 1 << SHIFT_OPCODE \
                    | int(match.group(2)) << SHIFT_RD \
                    | int(match.group(3)) << SHIFT_RA \
                    | int(match.group(4)) << SHIFT_RB
            if match.group(1) == 'u':
                instruction |= 1 << SHIFT_MODE
            elif match.group(1) == 's':
                pass
            else:
                raise Exception('Mode "{}" does not exist'.format(match.group(1)))
            output.append(instruction)

        elif match := re.fullmatch(ADDI, line):
            print("{}: addi".format(line))
            instruction = int(match.group(2)) << SHIFT_RD \
                    | int(match.group(3)) << SHIFT_RA \
                    | two_complement(int(match.group(4)), 4) << SHIFT_IMMEDIATE_ADD_SUB \
                    | 1
            if match.group(1) == 'u':
                instruction |= 1 << SHIFT_MODE
            elif match.group(1) == 's':
                pass
            else:
                raise Exception('Mode "{}" does not exist'.format(match.group(1)))
            output.append(instruction)

        elif match := re.fullmatch(SUBI, line):
            print("{}: subi".format(line))
            instruction = 1 << SHIFT_OPCODE \
                    | int(match.group(2)) << SHIFT_RD \
                    | int(match.group(3)) << SHIFT_RA \
                    | two_complement(int(match.group(4)), 4) << SHIFT_IMMEDIATE_ADD_SUB \
                    | 1
            if match.group(1) == 'u':
                instruction |= 1 << SHIFT_MODE
            elif match.group(1) == 's':
                pass
            else:
                raise Exception('Mode "{}" does not exist'.format(match.group(1)))
            output.append(instruction)

        elif match := re.fullmatch(OR, line):
            print("{}: or".format(line))
            instruction = 2 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            if match.group(4):
                instruction |= int(match.group(5)) << SHIFT_RB
            else:
                instruction |= int(match.group(6))
                instruction |= 1 << SHIFT_MODE
            output.append(instruction)

        elif match := re.fullmatch(AND, line):
            print("{}: and".format(line))
            instruction = 3 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            if match.group(4):
                instruction |= int(match.group(5)) << SHIFT_RB
            else:
                instruction |= int(match.group(6))
                instruction |= 1 << SHIFT_MODE
            output.append(instruction)

        elif match := re.fullmatch(XOR, line):
            print("{}: xor".format(line))
            instruction = 4 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            if match.group(4):
                instruction |= int(match.group(5)) << SHIFT_RB
            else:
                instruction |= int(match.group(6))
                instruction |= 1 << SHIFT_MODE
            output.append(instruction)

        elif match := re.fullmatch(NOT, line):
            print("{}: not".format(line))
            instruction = 5 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            output.append(instruction)

        elif match := re.fullmatch(READW, line):
            print("{}: readw".format(line))
            instruction = 6 << SHIFT_OPCODE \
                    | 1 << SHIFT_MODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            if match.group(3):
                instruction |= int(match.group(4))
            output.append(instruction)

        elif match := re.fullmatch(READB, line):
            print("{}: readb".format(line))
            instruction = 6 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            if match.group(3):
                instruction |= int(match.group(4))
            output.append(instruction)

        elif match := re.fullmatch(WRITEW, line):
            print("{}: writew".format(line))
            instruction = 7 << SHIFT_OPCODE \
                    | 1 << SHIFT_MODE \
                    | int(match.group(1)) << SHIFT_RA \
                    | int(match.group(2)) << SHIFT_RB
            if match.group(3):
                instruction |= (int(match.group(4)) & 28) << SHIFT_RD
                instruction |= (int(match.group(4)) & 3)
            output.append(instruction)

        elif match := re.fullmatch(WRITEB, line):
            print("{}: writeb".format(line))
            instruction = 7 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RA \
                    | int(match.group(2)) << SHIFT_RB
            if match.group(3):
                instruction |= (int(match.group(4)) & 28) << SHIFT_RD
                instruction |= (int(match.group(4)) & 3)
            output.append(instruction)

        elif match := re.fullmatch(LOAD, line):
            print("{}:load".format(line))
            instruction = 8 << SHIFT_OPCODE \
                    | int(match.group(2)) << SHIFT_RD \
                    | int(match.group(3))
            if match.group(1) == 'h':
                instruction |= 1 << SHIFT_MODE
            elif match.group(1) == 'l':
                pass
            else:
                raise Exception('Mode "{}" does not exist'.format(match.group(1)))
            output.append(instruction)

        elif match := re.fullmatch(CMP, line):
            print("{}: cmp".format(line))
            instruction = 9 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA \
                    | int(match.group(3)) << SHIFT_RB
            output.append(instruction)

        elif match := re.fullmatch(SHIFTL, line):
            print("{}: shiftl".format(line))
            instruction = 10 << SHIFT_OPCODE \
                   | int(match.group(1)) << SHIFT_RD \
                   | int(match.group(2)) << SHIFT_RA
            if match.group(3):
                instruction |= int(match.group(4))
            output.append(instruction)

        elif match := re.fullmatch(SHIFTR, line):
           print("{}: shiftr".format(line))
           instruction = 10 << SHIFT_OPCODE \
                   | 1 << SHIFT_MODE \
                   | int(match.group(1)) << SHIFT_RD \
                   | int(match.group(2)) << SHIFT_RA
           if match.group(3):
               instruction |= int(match.group(4))
           output.append(instruction)

        elif match := re.fullmatch(BI, line):
           print("{}: bi".format(line))
           if not match.group(1) in labels:
               raise Exception("Label '{}' not defined.".format(match.group(1)))

           instruction = 11 << SHIFT_OPCODE \
                   | two_complement((labels[match.group(1)] - pos), 8)
           output.append(instruction)

        elif match := re.fullmatch(BR, line):
           print("{}: br".format(line))
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(2)) << SHIFT_RA \
                   | int(match.group(3)) << SHIFT_RB
           if match.group(1) == 'eq':
               instruction |= 0 << SHIFT_RD
           elif match.group(1) == 'gt':
               instruction |= 1 << SHIFT_RD
           elif match.group(1) == 'lt':
               instruction |= 2 << SHIFT_RD
           elif match.group(1) == 'az':
               instruction |= 3 << SHIFT_RD
           elif match.group(1) == 'bz':
               instruction |= 4 << SHIFT_RD
           else:
               raise Exception("Unknown branch mode '{}'".format(match.group(1)));
           output.append(instruction)

        elif match := re.fullmatch(BRO, line):
           print("{}: bro".format(line))
           instruction = 12 << SHIFT_OPCODE \
                   | 1 << SHIFT_MODE \
                   | int(match.group(2)) << SHIFT_RA \
                   | two_complement((labels[match.group(3)] - pos), 8)
           if match.group(1) == 'eq':
               instruction |= 0 << SHIFT_RD
           elif match.group(1) == 'gt':
               instruction |= 1 << SHIFT_RD
           elif match.group(1) == 'lt':
               instruction |= 2 << SHIFT_RD
           elif match.group(1) == 'az':
               instruction |= 3 << SHIFT_RD
           elif match.group(1) == 'bz':
               instruction |= 4 << SHIFT_RD
           else:
               raise Exception("Unknown branch mode '{}'".format(match.group(1)));
           output.append(instruction)

        elif match := re.fullmatch(SPC, line):
           print("{}: spc".format(line))
           instruction = 13 << SHIFT_OPCODE \
                   | int(match.group(1)) << SHIFT_RD

        elif match := re.fullmatch(LABEL, line):
            # do not increase the offset counter
           continue

        else:
           raise Exception("Unknown instruction '{}'".format(line))

        pos += 2

if options.ascii:
    with open(options.output_file, 'w') as f:
        for op in output:
            f.write(str(op) + '\n');
else:
    with open(options.output_file, 'wb') as f:
        for op in output:
            f.write(op.to_bytes(2, 'little'))
