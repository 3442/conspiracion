__all__ = ['SmpModel']

class SmpModel:
    def __init__(self):
        self._pes = [
            SmpPe(0),
            SmpPe(1),
            SmpPe(1),
            SmpPe(1)]

    def read(self):
        return self._pes[0].read() \
                | self._pes[1].read() << 8 \
                | self._pes[2].read() << 16 \
                | self._pes[3].read() << 24

    def halt(self, cpu):
        self._pes[cpu].halt()

    def run(self, cpu):
        self._pes[cpu].run()

class SmpPe:
    def __init__(self, halt_on_reset):
        self._bkpt = 0
        self._halted = halt_on_reset

    def read(self):
        # bit 2 es alive
        return 1 << 2 \
            | self._bkpt << 1 \
            | self._halted

    def halt(self):
        self._halted = 1

    def run(self):
        self._halted = 0
