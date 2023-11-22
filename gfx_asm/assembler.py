#!/usr/bin/env python3

import ast, sys, string, struct

REG_STACK     = 14
REG_LINK      = 15
LABEL_CHARSET = string.ascii_letters + '_'

REG_MAP = {
    'm0': 0,
    'm1': 1,
    'm2': 2,
    'm3': 3,
    'm4': 4,
    'm5': 5,
    'm6': 6,
    'm7': 7,
}


class Ins:
    def __init__(self, *args, name, line, addr):
        self.name = name
        self.line = line
        self.addr = addr
        self.args = iter(args)

    def imm_pool(self, pool):
        pass

    def length(self):
        return 1

    def stop(self):
        try:
            next(self.args)
        except StopIteration:
            pass
        else:
            self.error(f"Too many arguments")

    def next(self, *, optional=False):
        try:
            return next(self.args)
        except StopIteration:
            if optional:
                return None

            self.error(f"Missing arguments")

    def error(self, msg):
        fail(self.line, f"{self.name}: {msg}")

    def parse_addr(self, *, zero=True):
        arg = self.next()

        if len(arg) < 2 or arg[0] != "[" or arg[-1] != "]":
            self.error(f"Invalid syntax: bad addressing mode: {repr(arg)}")

        return self.parse_reg(arg=arg[1:-1], zero=zero)

    def parse_imm(self, *, zero=True):
        arg, bad = self.next(), False

        try:
            imm = int(arg, 0)
        except ValueError:
            bad = True

        if bad:
            try:
                imm = ast.literal_eval(arg)
                if type(imm) is str:
                    imm = imm.encode('ascii')
                    if len(imm) == 1:
                        imm = imm[0]
                        bad = False
            except:
                pass

        if bad:
            self.error(f"Invalid immediate value: {repr(arg)}")
        elif not zero and not imm:
            self.error("Immediate value must not be 0.")
        elif not (-(1 << 31) <= imm <= (1 << 32) - 1):
            self.error(f"Immediate exceeds 32 bits: {imm}")

        return imm

    def parse_reg(self, *, zero=True, arg=None, expect=None, optional=False):
        if not arg:
            arg = self.next(optional=optional)
            if arg is None:
                return None

        arg = arg.lower()
        if (reg := REG_MAP.get(arg)) is None:
            self.error(f"Invalid register: {repr(arg)}")
        elif not zero and not reg:
            self.error("Register must not be r0")
        elif expect is not None and reg != expect:
            self.error(f"Expected register r{expect}, got r{reg}")

        return reg

    def parse_target(self):
        arg = self.next()
        if arg == '.':
            return self.addr

        if not arg or any(c not in LABEL_CHARSET for c in arg):
            self.error(f"Invalid label: {repr(arg)}")

        return arg

    def encode_reg(self, reg):
        return self.encode_unsigned(reg, 3)

    def encode_rel(self, labels, label, size, *, offset=1):
        addr = labels.get(label) if type(label) is str else label

        if addr is None:
            self.error(f"Undefined reference to {repr(label)}")

        return self.encode_signed(addr - self.addr - offset, size, tag="Jump")

    def encode_signed(self, val, size, *, tag="Value"):
        lo, hi = -(1 << (size - 1)), (1 << (size - 1)) - 1
        if not (lo <= val <= hi):
            self.error(f"{tag} out of range [{lo}, {hi}]: {val}")

        elif val < 0:
            val += 1 << size

        return self.encode_unsigned(val, size)

    def encode_unsigned(self, val, size):
        hi = (1 << size) - 1
        if not (0 <= val <= hi):
            self.error(f"Value out of range [0, {hi}]: {val}")

        return bin(val)[2:].zfill(size)


class Select(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.dst = self.parse_reg()
        self.src_a = self.parse_reg()
        self.src_b = self.parse_reg()

        components = {'a': '0', 'b': '1'}

        arg = self.next()
        self.select = [components.get(v) for v in arg.lower()]

        if len(self.select) != 4 or any(v is None for v in self.select):
            self.error(f"Bad select mask: {repr(arg)}")


    def encode(self, labels):
        dst = self.encode_reg(self.dst)
        src_a, src_b = self.encode_reg(self.src_a), self.encode_reg(self.src_b)
        return ('00000000', ''.join(self.select), '0', src_b, '0', src_a, '0', dst, '00000001')


class Swizzle(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.dst = self.parse_reg()
        self.src = self.parse_reg()

        components = {'x': 3, 'y': 2, 'z': 1, 'w': 0}

        mask_arg = self.next()
        self.masks = [components.get(v) for v in mask_arg.lower()]

        if len(self.masks) != 4 or any(v is None for v in self.masks):
            self.error(f"Bad swizzle mask: {repr(mask_arg)}")

    def encode(self, labels):
        dst = self.encode_reg(self.dst)
        src = self.encode_reg(self.src)
        mask = ''.join(self.encode_unsigned(mask, 2) for mask in self.masks)
        print(mask, file=sys.stderr)
        return (mask, '000000000', src, '0', dst, '00000010')


class Broadcast(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.dst = self.parse_reg()

        imm = self.next()
        try:
            self.imm = float(imm)
        except:
            self.error(f"Invalid immediate value: {repr(imm)}")

    def encode(self, labels):
        imm = self.encode_unsigned(int.from_bytes(struct.pack('<e', self.imm), 'little'), 16)
        dst = self.encode_reg(self.dst)
        return (imm, '00000', dst, '00000100')


class MatVec(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.dst = self.parse_reg()
        self.src_a = self.parse_reg()
        self.src_b = self.parse_reg()

    def encode(self, labels):
        dst = self.encode_reg(self.dst)
        src_a, src_b = self.encode_reg(self.src_a), self.encode_reg(self.src_b)
        return ('0000000000000', src_b, '0', src_a, '0', dst, '00001000')


class Send(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.src = self.parse_reg()

    def encode(self, labels):
        src = self.encode_reg(self.src)
        return ('00000000000000000', src, '000000010000')


class Recv(Ins):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)

        self.dst = self.parse_reg()

    def encode(self, labels):
        dst = self.encode_reg(self.dst)
        return ('000000000000000000000', dst, '00100000')


ISA = {
    "select": Select,
    "swizzl": Swizzle,
    "broadc": Broadcast,
    "matvec": MatVec,
    "send": Send,
    "recv": Recv,
}


def fail(line, msg):
    print("At line ", line, ": ", msg, sep="", file=sys.stderr)
    sys.exit(1)


def assemble(file):
    pc = 0
    insns = []
    labels = {}
    imm_labels = {}

    def get_imm_label(imm):
        nonlocal imm_labels

        if imm < 0:
            imm += 1 << 32

        label = imm_labels.get(imm)
        if not label:
            label = f'#{hex(imm)[2:].zfill(8)}'
            imm_labels[imm] = label

        return label

    with open(file, "r") as src:
        for lineno, line in enumerate(src, start=1):
            ## comments
            if (i := line.find("!")) != -1:
                line = line[:i]

            line = line.strip()

            if len(line) > 1 and line[-1] == ":":
                label = line[:-1]

                if any(c not in LABEL_CHARSET for c in label):
                    fail(lineno, f"Invalid label: {repr(label)}")
                elif label in labels:
                    fail(lineno, f"Label already in use: {repr(label)}")

                labels[label] = pc

                continue

            line = line.split(maxsplit=1)

            ## empty lines
            if not line:
                continue

            args = (arg.strip() for arg in line[1].split(",")) if len(line) > 1 else ()
            name = line[0].lower()

            ctor = ISA.get(name)

            if not ctor:
                fail(lineno, f"Unknown instruction: {repr(name)}")

            insn = ctor(*args, name=name, line=lineno, addr=pc)
            insn.stop()
            insn.imm_pool(get_imm_label)

            insns.append(insn)
            pc += insn.length()

    # Inmediatos tienen que estar alineados a words
    imm_pool_padding = bool(pc & 1)
    if imm_pool_padding:
        pc += 1

    imm_labels = list(imm_labels.items())
    for imm, label in imm_labels:
        labels[label] = pc
        pc += 2

    output = bytearray()

    for insn in insns:
        encs = insn.encode(labels)

        if type(encs) is not list:
            encs = [encs]

        assert len(encs) == insn.length()

        for enc in encs:
            enc = "".join(enc)
            assert len(enc) == 32 and all(c in ("0", "1") for c in enc)

            output.extend(int(enc, 2).to_bytes(4, "little"))

    return output


def main():
    sys.stdout.buffer.write(assemble(sys.argv[1]))


if __name__ == "__main__":
    main()
