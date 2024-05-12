#include <cmath>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <string>
#include <strings.h>

#include <SDL2/SDL.h>
#include <verilated.h>

#if VM_TRACE
#include <verilated_fst_c.h>
#endif

#include "Vtop.h"

#include "remote_bitbang.h"

int main(int argc, char **argv)
{
	Verilated::commandArgs(argc, argv);
	Vtop top;

#if VM_TRACE
	Verilated::traceEverOn(true);

	VerilatedFstC trace;
	top.trace(&trace, 0);
	trace.open("dump.fst");
#endif

	int time = 0;

	auto cycle = [&]()
	{
		top.eval();
#if VM_TRACE
		trace.dump(time++);
#endif
		top.clk = 1;

		top.eval();
#if VM_TRACE
		trace.dump(time++);
#endif
		top.clk = 0;
	};

	top.clk = 0;
	top.rst_n = 0;
	top.jtag_tck = 0;
	top.jtag_tms = 0;
	top.jtag_tdi = 0;
	cycle();

	top.rst_n = 1;
	cycle();

	rbs_init(1234);

	do {
		cycle();

		unsigned char tck = top.jtag_tck;
		unsigned char tms = top.jtag_tms;
		unsigned char tdi = top.jtag_tdi;
		unsigned char trstn = 1;

		rbs_tick(&tck, &tms, &tdi, &trstn, top.jtag_tdo);

		top.jtag_tck = tck;
		top.jtag_tms = tms;
		top.jtag_tdi = tdi;
	} while (!(client_fd < 0));

#if VM_TRACE
	trace.close();
#endif

	top.final();

	return EXIT_SUCCESS;
}
