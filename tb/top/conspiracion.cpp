#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <iostream>
#include <string>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vconspiracion.h"
#include "Vconspiracion_arm810.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"
#include "Vconspiracion_core_regs.h"
#include "Vconspiracion_core_reg_file.h"

#include "../args.hxx"

#include "../avalon.hpp"
#include "../mem.hpp"

namespace
{
	struct mem_region
	{
		std::size_t start;
		std::size_t length;
	};


	std::istream &operator>>(std::istream &stream, mem_region &region)
	{
		stream >> region.start;
		stream.get();
		stream >> region.length;
		return stream;
	}

	constexpr const char *gp_regs[30] =
	{
		[0] = "0",
		[1] = "1",
		[2] = "2",
		[3] = "3",
		[4] = "4",
		[5] = "5",
		[6] = "6",
		[7] = "7",
		[8] = "8_usr",
		[9] = "9_usr",
		[10] = "10_usr",
		[11] = "11_usr",
		[12] = "12_usr",
		[13] = "13_usr",
		[14] = "14_usr",
		[15] = "8_fiq",
		[16] = "9_fiq",
		[17] = "10_fiq",
		[18] = "11_fiq",
		[19] = "12_fiq",
		[20] = "13_fiq",
		[21] = "14_fiq",
		[22] = "13_irq",
		[23] = "14_irq",
		[24] = "13_und",
		[25] = "14_und",
		[26] = "13_abt",
		[27] = "14_abt",
		[28] = "13_svc",
		[29] = "14_svc",
	};
}

int main(int argc, char **argv)
{
	using namespace taller::avalon;

	Verilated::commandArgs(argc, argv);

	args::ArgumentParser parser("Simulador proyecto final CE3201");

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
		parser, "region", "Dump a memory region", {"dump-mem"}
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

		const auto &regfile = top.conspiracion->core->regs->a->file;

		int i = 0;
		for(const auto *name : gp_regs)
		{
			std::printf("%08x r%s\n", regfile[i++], name);
		}
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
