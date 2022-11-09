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

    // sim/control_flow.c
    uint32_t rom[] =
    {
        0xea000032,
        0xea000034,
        0xea000000,
        0xeafffffe,
        0xeafffffe,
        0xeafffffe,
        0xeafffffe,
        0xe3500000,
        0xda000001,
        0xe3a00001,
        0xe1a0f00e,
        0x13e00000,
        0x03a00000,
        0xe1a0f00e,
        0xe1a02000,
        0xe92d4010,
        0xe1a00002,
        0xebfffff4,
        0xe1a03000,
        0xe1a00001,
        0xebfffff1,
        0xe0933000,
        0x0a00000c,
        0xe3730001,
        0x0a00000e,
        0xe3530001,
        0x0a00000a,
        0xe1a038a1,
        0xe1a00502,
        0xe1833601,
        0xe02023c2,
        0xe0831001,
        0xe1520001,
        0xcaffffed,
        0xe0820001,
        0xe8bd8010,
        0xe1a02822,
        0xe1822801,
        0xe1a00f62,
        0xe8bd8010,
        0xe3500000,
        0xda000002,
        0xe1a02001,
        0xe2611001,
        0xeafffff2,
        0xe1e02001,
        0xe1a00002,
        0xebffffd6,
        0xe3500000,
        0xdaffffed,
        0xe1a01002,
        0xeafffff5,
        0xe59fd008,
        0xebffffd7,
        0xeafffffe,
        0xeafffffe,
        0x20000000,
    };

    int clk_tick = 0;
	int time = 0;

	for(int i = 0; i < sizeof(rom)/sizeof(rom[0]); ++i) 
    {
        top.insn = rom[i];

        top.eval();
        trace.dump(time++);
    
        std::printf("insn=0x%08x, dec=0x", top.insn);
		for(std::size_t j = 0; j < sizeof(top.dec) / sizeof(top.dec[0]); ++j)
		{
			std::printf("%08x", top.dec[j]);
		}

		std::puts("");
    }

	trace.close();
    top.final();               // Done simulating
}
