#include <cstdio>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vdecode_test.h"               // From Verilating "top.v"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);   // Remember args
	Verilated::traceEverOn(true);

	Vdecode_test top;
	VerilatedVcdC trace;

	top.trace(&trace, 0);
	trace.open("decode_test.vcd");

    unsigned long instructions[3] = {3766898695, 
                                     3825578010, 
                                     3120562179};
    top.n = 0;
    top.z = 0;
    top.c = 0;
    top.v = 0;

    int clk_tick = 0;
	int time = 0;

	for(int i = 0; i < sizeof(instructions); ++i) 
    {
        top.insn = instructions[i];
        top.n = 0;
        top.z = 0;
        top.c = 0;
        top.v = 0;

        top.eval();
        trace.dump(time++);

        std::printf(" [%c%c%c%c]\n",
            top.n ? 'N' : 'n',
            top.z ? 'Z' : 'z',
            top.c ? 'C' : 'c',
            top.v ? 'V' : 'v');

        std::printf("insn=%d, ctrl=%d", 
                    instructions[i], top.ctrl);
    }

	trace.close();
    top.final();               // Done simulating
}
