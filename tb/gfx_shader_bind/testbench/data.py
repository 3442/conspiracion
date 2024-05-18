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
            return self.group == other.group and \
                    ((other.insn is None and self.insn is None) or \
                    (other.insn is not None and (not self.insn or self.insn == other.insn)))

        return self.group == other.group and self.insn == other.insn

    def __repr__(self):
        insn = f', insn=0x{self.insn:08x}' if not self.retry else ''
        soft = f', soft' if self._soft else ''
        return f'FrontWave(group={self.group}, retry={int(self.retry)}{insn}{soft})'
