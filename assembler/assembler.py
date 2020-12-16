import re, sys
from optparse import OptionParser

LABEL   = "(\w+):"
ADD     = "add r(\d), r(\d), r(\d)"
SUB     = "sub r(\d), r(\d), r(\d)"
NOT     = "not r(\d), r(\d)"
OR      = "or r(\d), r(\d)"
AND     = "and r(\d), r(\d)"
XOR     = "xor r(\d), r(\d)"
READ    = "read r(\d), r(\d)"
WRITE   = "write r(\d), r(\d)" 
LOAD    = "not r(\d), (\d{1,3})"
CMP     = "cmp r(\d), r(\d), r(\d)"
SHIFTL  = "shftl r(\d), r(\d)"
SHIFTR  = "shftr r(\d), r(\d)"
JMP     = "jmp r(\d), -?(\d{1,3})"
JMPEQ   = "jmpeq r(\d), r(\d)"
JMPRAGT = "jmpragt r(\d), r(\d)"
JMPRBGT = "jmprbgt r(\d), r(\d)"
JMPRAZ  = "jmpraz r(\d), r(\d)"
JMPRBZ  = "jmprbz r(\d), r(\d)"

SHIFT_OPCODE = 12
SHIFT_RD     = 9
SHIFT_RA     = 5
SHIFT_RB     = 2

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

    for line in lines:
        instruction = 0

        if match := re.fullmatch(LABEL, line):
            if match.group(1) in labels:
                raise Exception('Label "{}" already exists'.format(match.group(1)))
            labels[match.group(1)] = pos

        elif match := re.fullmatch(ADD, line):
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
            output.append(instruction)

        elif match := re.fullmatch(WRITE, line):
            instruction = 7 << SHIFT_OPCODE \
                    | int(match.group(1)) << SHIFT_RA \
                    | int(match.group(2)) << SHIFT_RB
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

        elif match := re.fullmatch(JMP, line):
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)

        elif match := re.fullmatch(JMPEQ, line):
           instruction = 13 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)

        elif match := re.fullmatch(JMPRAGT, line):
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)

        elif match := re.fullmatch(JMPRBGT, line):
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)

        elif match := re.fullmatch(JMPRAZ, line):
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)

        elif match := re.fullmatch(JMPRBZ, line):
           instruction = 12 << SHIFT_OPCODE \
                   | int(match.group(1))
           output.append(instruction)


        pos += 2

if options.ascii:
    with open(options.output_file, 'w') as f:
        for op in output:
            f.write(str(op) + '\n');
else:
    with open(options.output_file, 'wb') as f:
        for op in output:
            f.write(op.to_bytes(2, 'little'))
