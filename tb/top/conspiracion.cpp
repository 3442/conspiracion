#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vconspiracion.h"
#include "Vconspiracion_arm810.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"
#include "Vconspiracion_core_control.h"
#include "Vconspiracion_core_psr.h"
#include "Vconspiracion_core_regs.h"
#include "Vconspiracion_core_reg_file.h"

#include "../args.hxx"

#include "../avalon.hpp"
#include "../mem.hpp"

namespace
{
	constexpr const char *gp_regs[30] =
	{
		[0] = "r0",
		[1] = "r1",
		[2] = "r2",
		[3] = "r3",
		[4] = "r4",
		[5] = "r5",
		[6] = "r6",
		[7] = "r7",
		[8] = "r8_usr",
		[9] = "r9_usr",
		[10] = "r10_usr",
		[11] = "r11_usr",
		[12] = "r12_usr",
		[13] = "r13_usr",
		[14] = "r14_usr",
		[15] = "r8_fiq",
		[16] = "r9_fiq",
		[17] = "r10_fiq",
		[18] = "r11_fiq",
		[19] = "r12_fiq",
		[20] = "r13_fiq",
		[21] = "r14_fiq",
		[22] = "r13_irq",
		[23] = "r14_irq",
		[24] = "r13_und",
		[25] = "r14_und",
		[26] = "r13_abt",
		[27] = "r14_abt",
		[28] = "r13_svc",
		[29] = "r14_svc",
	};

	struct mem_region
	{
		std::size_t start;
		std::size_t length;
	};

	struct reg_init
	{
		std::size_t   index;
		std::uint32_t value;
	};

	std::istream &operator>>(std::istream &stream, mem_region &region)
	{
		stream >> region.start;
		if(stream.get() == ',')
		{
			stream >> region.length;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	std::istream &operator>>(std::istream &stream, reg_init &init)
	{
		char name[16];
		stream.getline(name, sizeof name, '=');

		std::size_t index = 0;
		constexpr auto total_gp_regs = sizeof gp_regs / sizeof gp_regs[0];

		while(index < total_gp_regs && std::strcmp(name, gp_regs[index]))
		{
			++index;
		}

		if(stream && !stream.eof() && index < total_gp_regs)
		{
			init.index = index;
			stream >> init.value;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}
}

int main(int argc, char **argv)
{
	using namespace taller::avalon;

	Verilated::commandArgs(argc, argv);

	for(char **arg = argv; *arg; ++arg)
	{
		if(**arg == '+')
		{
			*arg = NULL;
			argc = arg - argv;
			break;
		}
	}

	args::ArgumentParser parser("Simulador proyecto final CE3201");

	args::ValueFlagList<reg_init> init_regs
	(
		parser, "reg=val", "Initialize a register", {"init-reg"}
	);

	args::Flag dump_regs
	(
		parser, "dump-regs", "Dump all registers", {"dump-regs"}
	);

	args::ValueFlag<unsigned> cycles
	(
		parser, "cycles", "Number of core cycles to run", {"cycles"}, 256
	);

	args::ValueFlagList<mem_region> dump_mem
	(
		parser, "addr,length", "Dump a memory region", {"dump-mem"}
	);

	args::Positional<std::string> image
	(
		parser, "image", "Executable image to run", args::Options::Required
	);

	try
	{
		parser.ParseCLI(argc, argv);
	} catch(args::Help)
	{
		std::cout << parser;
		return EXIT_SUCCESS;
	} catch(args::ParseError e)
	{
		std::cerr << e.what() << std::endl;
		std::cerr << parser;
		return EXIT_FAILURE;
	} catch(args::ValidationError e)
	{
		std::cerr << e.what() << std::endl;
		std::cerr << parser;
		return EXIT_FAILURE;
	}

	Vconspiracion top;
	VerilatedVcdC trace;

	bool enable_trace = std::getenv("TRACE");
	if(enable_trace)
	{
		Verilated::traceEverOn(true);
		top.trace(&trace, 0);
		trace.open("trace.vcd");
	}

	interconnect<Vconspiracion_platform> avl(*top.conspiracion->plat);
	mem hps_ddr3(0x0000'0000, 512 << 20);

	avl.attach(hps_ddr3);

	FILE *img_file = std::fopen(image->c_str(), "rb");
	if(!img_file)
	{
		std::perror("fopen()");
		return EXIT_FAILURE;
	}

	hps_ddr3.load([&](std::uint32_t *buffer, std::size_t words)
	{
		return std::fread(buffer, 4, words, img_file);
	});

	std::fclose(img_file);

	for(const auto &init : init_regs)
	{
		auto &regs = *top.conspiracion->core->regs;
		regs.a->file[init.index] = init.value;
		regs.b->file[init.index] = init.value;
	}

	int time = 0;
	top.clk_clk = 1;

	auto tick = [&]()
	{
		top.clk_clk = !top.clk_clk;
		top.eval();
		avl.tick(top.clk_clk);

		if(enable_trace)
		{
			trace.dump(time++);
		}
	};

	auto cycle = [&]()
	{
		tick();
		tick();
	};

	top.halt = 0;
	top.rst_n = 0;
	cycle();
	top.rst_n = 1;

	for(unsigned i = 0; i < *cycles; ++i)
	{
		cycle();
	}

	if(enable_trace)
	{
		trace.close();
	}

	if(dump_regs)
	{
		std::puts("=== dump-regs ===");

		const auto &core = *top.conspiracion->core;
		const auto &regfile = core.regs->a->file;

		int i = 0;
		for(const auto *name : gp_regs)
		{
			std::printf("%08x %s\n", regfile[i++], name);
		}

		std::printf("%08x pc\n", core.control->pc << 2);
		std::printf("%08x cpsr\n", core.psr->cpsr_word);
		std::printf("%08x spsr_svc\n", core.psr->spsr_svc_word);
		std::printf("%08x spsr_abt\n", core.psr->spsr_abt_word);
		std::printf("%08x spsr_und\n", core.psr->spsr_und_word);
		std::printf("%08x spsr_fiq\n", core.psr->spsr_fiq_word);
		std::printf("%08x spsr_irq\n", core.psr->spsr_irq_word);
	}

	const auto &dumps = *dump_mem;
	if(!dumps.empty())
	{
		std::puts("=== dump-mem ===");
	}

	for(const auto &dump : dumps)
	{
		std::printf("%08x ", static_cast<std::uint32_t>(dump.start));
		for(std::size_t i = 0; i < dump.length; ++i)
		{
			auto word = avl.dump(dump.start + i);
			word = (word & 0xff) << 24
				 | ((word >> 8) & 0xff) << 16
				 | ((word >> 16) & 0xff) << 24
				 | ((word >> 24) & 0xff);

			std::printf("%08x", word);
		}

		std::putchar('\n');
	}

	top.final();
	return EXIT_SUCCESS;
}
