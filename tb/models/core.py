import random

import cocotb
from cocotb.triggers import ClockCycles

class CorePaceModel:
    def __init__(self, *, clk, halt, step, bkpt, halted):
        self._clk = clk
        self._halt = halt
        self._step = step
        self._bkpt = halted
        self._halted = halted

        self._bkpt.value = 0
        self._halted.value = 0

    async def run(self):
        while True:
            # Señales de step y halt pueden tomar algunas ciclos en surtir
            # efecto, dependiendo de lo que esté ocurriendo en la pipeline
            await ClockCycles(self._clk, random.randint(0, 10))
            self._halted.value = self._step.value or self._halt.value
