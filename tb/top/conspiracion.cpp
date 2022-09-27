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

	/*     mov r0, #69
	 *     mov r1, #-10
	 * loop1:
	 *     tst r1, r1
	 *     beq loop2
	 *     add r1, r1, #1
	 *     sub r0, r0, #1
	 *     b   loop1
	 * loop2:
	 *     b   loop2
	 */
	hps_ddr3.write(0, 0xe3a00045);
	hps_ddr3.write(1, 0xe3e01009);
	hps_ddr3.write(2, 0xe1110001);
	hps_ddr3.write(3, 0x0a000002);
	hps_ddr3.write(4, 0xe2811001);
	hps_ddr3.write(5, 0xe2400001);
	hps_ddr3.write(6, 0xeafffffa);
	hps_ddr3.write(7, 0xeafffffe);

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
	};

	for(int i = 0; i < 256; ++i)
	{
		cycle();
	}

#ifdef TRACE
	trace.close();
#endif

    top.final();
}
