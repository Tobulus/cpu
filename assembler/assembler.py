import re, sys
from optparse import OptionParser

LABEL   = "(\w+):"
ADD     = "add r(\d), r(\d), r(\d)"
SUB     = "sub r(\d), r(\d), r(\d)"
NOT     = "not r(\d), r(\d)"
OR      = "or r(\d), r(\d)"
AND     = "and r(\d), r(\d)"
XOR     = "xor r(\d), r(\d)"
READ    = "read r(\d), r(\d)(, r(\d))?"
WRITE   = "write r(\d), r(\d)(, r(\d)?)" 
LOAD    = "not r(\d), (\d{1,3})"
CMP     = "cmp r(\d), r(\d), r(\d)"
SHIFTL  = "shftl r(\d), r(\d)"
SHIFTR  = "shftr r(\d), r(\d)"
BI      = "bi $(\w+)"
BR      = "br.(gt|lt|az|bz|eq) r(\d), r(\d)"
BROEQ   = "bro.(gt|lt|az|bz|eq) r(\d), $(\w+))"
SPC     = "spc r(\d)"

SHIFT_OPCODE = 12
SHIFT_RD     = 9
SHIFT_MODE   = 8
SHIFT_RA     = 5
SHIFT_RB     = 2

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

    # parse instructions
    pos = 0
    for line in lines:
        instruction = 0

        if match := re.fullmatch(ADD, line):
            instruction = int(match.group(1)) << SHIFT_RD \
                          | int(match.group(2)) << SHIFT_RA \
                          | int(match.group(3)) << SHIFT_RB
            output.append(instruction)

        elif match := re.fullmatch(SUB, line):
            instruction = 1 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA \
                    | int(match.group(3)) << SHIFT_RB
            output.append(instruction)

        elif match := re.fullmatch(OR, line):
            instruction = 2 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            output.append(instruction)

        elif match := re.fullmatch(AND, line):
            instruction = 3 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            output.append(instruction)

        elif match := re.fullmatch(XOR, line):
            instruction = 4 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            output.append(instruction)

        elif match := re.fullmatch(NOT, line):
            instruction = 5 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) << SHIFT_RA
            output.append(instruction)

        elif match := re.fullmatch(READ, line):
            instruction = 6 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RA \
                    | int(match.group(2)) << SHIFT_RB
            if match.group(3):
                instruction |= int(match.group(4))
            output.append(instruction)

        elif match := re.fullmatch(WRITE, line):
            instruction = 7 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RA \
                    | int(match.group(2)) << SHIFT_RB
            if match.group(3):
                instruction |= int(match.group(4))
            output.append(instruction)

        elif match := re.fullmatch(LOAD, line):
            instruction = 8 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RD \
                    | int(match.group(2)) 
            output.append(instruction)

        elif match := re.fullmatch(CMP, line):
           instruction = 9 << SHIFT_OPCODE \
                   | int(match.group(1)) << SHIFT_RD \
                   | int(match.group(2)) << SHIFT_RA \
                   | int(match.group(3)) << SHIFT_RB
           output.append(instruction)

        elif match := re.fullmatch(SHIFTL, line):
           instruction = 10 << SHIFT_OPCODE \
                   | int(match.group(1)) << SHIFT_RD \
                   | int(match.group(2)) << SHIFT_RA
           output.append(instruction)

        elif match := re.fullmatch(SHIFTR, line):
           instruction = 11 << SHIFT_OPCODE \
                   | int(match.group(1)) << SHIFT_RD \
                   | int(match.group(2)) << SHIFT_RA
           output.append(instruction)

        elif match := re.fullmatch(BI, line):
           if not match.group(1) in labels:
               raise Exception("Label '{}' not defined.".format(match.group(1)))

           instruction = 12 << SHIFT_OPCODE \
                   | CMP_EQ << SHIFT_RD \
                   | (labels[match.group(1)] - pos)
           output.append(instruction)

        elif match := re.fullmatch(BR, line):
           instruction = 13 << SHIFT_OPCODE \
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
           instruction = 13 << SHIFT_OPCODE \
                   | 1 << SHIFT_MODE \
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

        elif match := re.fullmatch(SPC, line):
            instruction = 14 << SHIFT_OPCODE \
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
