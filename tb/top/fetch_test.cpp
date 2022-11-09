#include <cstdio>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vfetch_test.h"               // From Verilating "top.v"

int main(int argc, char** argv) {
    Verilated::commandArgs(argc, argv);   // Remember args
	Verilated::traceEverOn(true);

	Vfetch_test top;
	VerilatedVcdC trace;

	top.trace(&trace, 0);
	trace.open("fetch_test.vcd");

    top.clk = 0;
    top.stall = 0;               //insn y insn_pc se detienen
    top.branch = 0;              //forma de flush -> instr saltan a la instr de la branch
    top.prefetch_flush = 0;      //limpia prefetch
    top.fetched = 1;             //estado del fetch (ready)
    top.wr_pc = 0;               //cuando hay un write al pc
    top.branch_target = 0;       //direccion a la que se hace salto
    top.wr_current = 0;          //ultimo que se guardo en registros
    top.fetch_data = 0x00000000; //data que se leyó al hacer fetch

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

    std::printf("CPU cycle:\n");
    while (time < 50) 
    {
        top.eval();
        trace.dump(time++);

        if(!top.clk)
        {
            std::printf("insn=0x%08x, insn_pc=0x%08x, addr=0x%08x\n", 
                    top.insn, top.insn_pc, top.addr);
        }

		top.clk = !top.clk;

        top.fetch_data = rom[top.addr];
    }

    std::printf("Branch, flush, stall:\n");
    while (time < 99) 
    {
        top.eval();
        trace.dump(time++);

        if(!top.clk)
        {
            std::printf("insn=0x%08x, insn_pc=0x%08x, addr=0x%08x\n", 
                    top.insn, top.insn_pc, top.addr);
        }

		top.clk = !top.clk;

        if(time == 55)
		{
            std::printf("Se hace un branch:\n");
			top.branch = 1;
            top.branch_target = 3;
		}

        if(time == 59)
		{
            std::printf("Se termina el branch:\n");
			top.branch = 0;

		}

        if(time == 63){
            std::printf("Se hace un flush:\n");
            top.branch = 0;
            top.branch_target = 0;
			top.prefetch_flush = 1;
		}

        if(time == 69){
            std::printf("Se termina el flush:\n");
			top.prefetch_flush = 0;
		}

        if(time == 75)
		{
            std::printf("Se hace un stall:\n");
			top.stall = 1;
		}

        if(time == 81)
		{
            std::printf("Se termina el stall:\n");
			top.stall = 0;
		}

        top.fetch_data = rom[top.addr];
    }

	trace.close();
    top.final();               // Done simulating
}
