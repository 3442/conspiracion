#include <verilated.h>
#include <cstdio>

#include "Vconspiracion.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"

#include "../avalon.hpp"

int main(int argc, char **argv)
{
	using namespace taller::avalon;

    Verilated::commandArgs(argc, argv);

	Vconspiracion top;
	interconnect<Vconspiracion_platform> avl(*top.conspiracion->plat);

	int time = 0;
	auto tick = [&]()
	{
		top.clk_clk = 0;
		top.eval();
		top.clk_clk = 1;
		top.eval();
		avl.tick();

		std::printf("[%02d] out=0x%02x, done=%d\n", ++time, top.out, top.done);
	};

	top.dir = 1;
	top.io = 1;
	top.mov = 1;
	top.clr = 1;

	for(int i = 0; i < 5; ++i)
	{
		top.add = 0;
		tick();
		top.add = 1;
		tick();
	}

	top.io = 0;
	tick();
	tick();

    top.final();
}
