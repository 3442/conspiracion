BAD_PC = 0xffff_ffff >> 2

class FrontWave:
    def __init__(self, *, group, insn, soft=False):
        self.group, self.insn = group, insn
        self.retry = insn is None
        self._soft = soft

    def __eq__(self, other):
        if self._soft and not other._soft:
            return other.__eq__(self)

        if other._soft:
            if self.group != other.group:
                return False
            elif other.insn is None and self.insn is None:
                return True
            elif other.insn is None:
                return False
            elif self.insn is None:
                return True
            elif type(other.insn) is tuple:
                return self.insn in other.insn
            else:
                return self.insn == other.insn

        return self.group == other.group and self.insn == other.insn

    def __repr__(self):
        if type(self.insn) is tuple:
            insn = '(' + ','.join(f'0x{insn:08x}' for insn in self.insn) + ')'
        elif self.insn is not None:
            insn = f'0x{self.insn:08x}'

        insn = f', insn={insn}' if not self.retry else ''
        soft = f', soft' if self._soft else ''
        return f'FrontWave(group={self.group}, retry={int(self.retry)}{insn}{soft})'
