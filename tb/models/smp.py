__all__ = ['SmpModel']

class SmpModel:
    def __init__(self):
        self._pe0 = SmpPe(0)
        self._pe1 = SmpPe(1)
        self._pe2 = SmpPe(1)
        self._pe3 = SmpPe(1)

    def read(self):
        return self._pe0.read() \
                | self._pe1.read() << 8 \
                | self._pe2.read() << 16 \
                | self._pe3.read() << 24

class SmpPe:
    def __init__(self, halt_on_reset):
        self._bkpt = 0
        self._halted = halt_on_reset

    def read(self):
        return self._bkpt << 1 | self._halted
