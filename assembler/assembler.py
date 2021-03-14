import re, sys
from optparse import OptionParser
from ops.op_add import op_add
from ops.op_sub import op_sub
from ops.op_and import op_and
from ops.op_or import op_or
from ops.op_xor import op_xor
from ops.op_not import op_not
from ops.op_cmp import op_cmp
from ops.op_load import op_load
from ops.op_shift import op_shift
from ops.op_mem_read import op_mem_read
from ops.op_mem_write import op_mem_write
from ops.op_branch import op_branch
from ops.op_spc import op_spc

LABEL   = "(\w+):"

optparser = OptionParser()
optparser.add_option("--ascii", action="store_true", dest="ascii")
optparser.add_option("--hex", action="store_true", dest="hex")
optparser.add_option("--input", action="store", type="string", dest="input_file")
optparser.add_option("--output", action="store", type="string", dest="output_file")
(options, args) = optparser.parse_args(sys.argv)

op_handlers = {}
output = []

handlers = []
handlers += [op_add(True)]
handlers += [op_add(False)]
handlers += [op_sub(True)]
handlers += [op_sub(False)]
handlers += [op_and()]
handlers += [op_or()]
handlers += [op_xor()]
handlers += [op_not()]
handlers += [op_shift(op_shift.MODE_LEFT)]
handlers += [op_shift(op_shift.MODE_RIGHT)]
handlers += [op_mem_write(op_mem_write.MODE_WORD)]
handlers += [op_mem_write(op_mem_write.MODE_BYTE)]
handlers += [op_mem_read(op_mem_read.MODE_WORD)]
handlers += [op_mem_read(op_mem_read.MODE_BYTE)]
handlers += [op_load(op_load.MODE_HIGH)]
handlers += [op_load(op_load.MODE_LOW)]
handlers += [op_cmp()]
handlers += [op_branch(True, op_branch.MODE_NONE)]
handlers += [op_branch(False, op_branch.MODE_EQ)]
handlers += [op_branch(False, op_branch.MODE_LT)]
handlers += [op_branch(False, op_branch.MODE_GT)]
handlers += [op_branch(False, op_branch.MODE_AZ)]
handlers += [op_branch(False, op_branch.MODE_BZ)]
handlers += [op_spc()]

for handler in handlers:
    op_handlers[handler.get_op()] = handler

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

        if re.fullmatch(LABEL, line):
            # do not increase the offset counter
           continue
        else:
            params = [x.strip() for x in line.split(" ", 1)[1].split(",")]
            output += [op_handlers[line.split(" ", 1)[0]].invoke(params, labels, pos)]
        pos += 2

if options.ascii:
    with open(options.output_file, 'w') as f:
        for op in output:
            if options.hex:
                # four character hex digit
                val = "{0:0{1}x}".format(op, 4)
                # switch byte ordering
                formatted = val[2:4] + ' ' + val[0:2]
                f.write(formatted + '\n');
            else:
                f.write(str(op) + '\n');
else:
    with open(options.output_file, 'wb') as f:
        for op in output:
            f.write(op.to_bytes(2, 'little'))
