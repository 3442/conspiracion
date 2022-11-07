#include <cstdio>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vmul_test.h"               // From Verilating "top.v"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);   // Remember args
	Verilated::traceEverOn(true);

	Vmul_test top;
	VerilatedVcdC trace;

	top.trace(&trace, 0);
	trace.open("mul_test.vcd");

    top.a = 6;
    top.b = 5;
    top.clk = 0;
    top.rst = 0;
    top.start = 0;
    top.result = 0;
    top.rdy = 0;
    top.c_hi = 0;
    top.c_lo = 0;


    int clk_tick = 0;
	int time = 0;

	for(int i = 0; i < 100; ++i) 
    {
        if(++clk_tick == 5)
		{
			clk_tick = 0;
			top.clk = !top.clk;
		}
        
        
        if(++clk_tick == 10)
        {
            top.rst = 1;
        }

        if(++clk_tick == 20)
        {
            top.start = 1;
        }

        if(++clk_tick == 30)
        {
            top.start = 0;
        }

        top.eval();
        trace.dump(time++);

        std::printf(" [%c%c%c%c]\n",
            top.n ? 'N' : 'n',
            top.z ? 'Z' : 'z',
            top.c ? 'C' : 'c',
            top.v ? 'V' : 'v');

        std::printf("a=%d, b=%d, ready=%d, result=%d, [N=%d, Z=%d]", 
                    top.a, top.b, top.rdy, top.result, top.n, top.z);
    }

	trace.close();
    top.final();               // Done simulating
}