#include <cstdio>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vconspiracion.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"

#include "../avalon.hpp"
#include "../mem.hpp"

int main(int argc, char **argv)
{
	using namespace taller::avalon;

    Verilated::commandArgs(argc, argv);

	Vconspiracion top;

#ifdef TRACE
	Verilated::traceEverOn(true);
	VerilatedVcdC trace;

	top.trace(&trace, 0);
	trace.open("trace.vcd");
#endif

	interconnect<Vconspiracion_platform> avl(*top.conspiracion->plat);
	mem hps_ddr3(0x0000'0000, 512 << 20);

	avl.attach(hps_ddr3);

	int time = 0;
	top.clk_clk = 1;

	auto tick = [&]()
	{
		top.clk_clk = !top.clk_clk;
		top.eval();
		avl.tick(top.clk_clk);
#ifdef TRACE
		trace.dump(time++);
#endif
	};

	auto cycle = [&]()
	{
		tick();
		tick();
		std::printf("[%02d] out=0x%02x, done=%d\n", time, top.out, top.done);
	};

	auto io = [&]()
	{
		top.io = 0;
		cycle();
		top.io = 1;
		for(int i = 0; i < 4; ++i)
		{
			cycle();
		}
	};

	top.dir = 1;
	top.io = 1;
	top.mov = 1;
	top.clr = 1;

	for(int i = 0; i < 5; ++i)
	{
		top.add = 0;
		cycle();
		top.add = 1;
		cycle();
	}

	io();

	top.clr = 0;
	cycle();
	top.clr = 1;
	cycle();

	top.dir = 0;
	io();

#ifdef TRACE
	trace.close();
#endif

    top.final();
}
