#include <climits>
#include <csignal>
#include <cstdio>
#include <cstdint>
#include <cstdlib>
#include <cstring>
#include <iostream>
#include <string>
#include <vector>

#include <unistd.h>

#include <verilated.h>
#include <verilated_vcd_c.h>

#include "Vconspiracion.h"
#include "Vconspiracion_arm810.h"
#include "Vconspiracion_conspiracion.h"
#include "Vconspiracion_platform.h"
#include "Vconspiracion_vga_domain.h"
#include "Vconspiracion_core.h"
#include "Vconspiracion_core_control.h"
#include "Vconspiracion_core_control_issue.h"
#include "Vconspiracion_core_cp15_domain.h"
#include "Vconspiracion_core_cp15_far.h"
#include "Vconspiracion_core_cp15_fsr.h"
#include "Vconspiracion_core_cp15_syscfg.h"
#include "Vconspiracion_core_cp15_ttbr.h"
#include "Vconspiracion_core_cp15.h"
#include "Vconspiracion_core_fetch.h"
#include "Vconspiracion_core_mmu.h"
#include "Vconspiracion_core_psr.h"
#include "Vconspiracion_core_regs.h"
#include "Vconspiracion_core_reg_file.h"
#include "Vconspiracion_cache.h"
#include "Vconspiracion_cache__T1.h"
#include "Vconspiracion_cache_sram.h"

#include "../args.hxx"

#include "../avalon.hpp"
#include "../const.hpp"
#include "../mem.hpp"
#include "../jtag_uart.hpp"
#include "../interval_timer.hpp"
#include "../null.hpp"
#include "../window.hpp"
#include "../vga.hpp"

namespace
{
	volatile sig_atomic_t async_halt = 0;

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

	struct mem_init
	{
		std::uint32_t addr;
		std::uint32_t value;
	};

	struct file_load
	{
		std::uint32_t addr;
		std::string   filename;
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

	std::istream &operator>>(std::istream &stream, mem_init &init)
	{
		stream >> init.addr;
		if(stream.get() == ',')
		{
			stream >> init.value;
		} else
		{
			stream.setstate(std::istream::failbit);
		}

		return stream;
	}

	std::istream &operator>>(std::istream &stream, file_load &load)
	{
		stream >> load.addr;
		if(stream.get() == ',')
		{
			stream >> load.filename;
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

	void async_halt_handler(int)
	{
		async_halt = 1;
	}
}

int main(int argc, char **argv)
{
	using namespace taller::avalon;
	using namespace taller::vga;

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

	args::Flag headless
	(
		parser, "headless", "Disable video output", {"headless"}
	);

	args::Flag accurate_video
	(
		parser, "accurate-video", "Enable signal-level video emulation", {"accurate-video"}
	);

	args::Flag no_tty
	(
		parser, "no-tty", "Disable TTY takeoveer", {"no-tty"}
	);

	args::Flag start_halted
	(
		parser, "start-halted", "Halt before running the first instruction", {"start-halted"}
	);

	args::ValueFlag<unsigned> cycles
	(
		parser, "cycles", "Max number of core cycles to run", {"cycles"}, 0
	);

	args::ValueFlag<int> control_fd
	(
		parser, "fd", "Control file descriptor", {"control-fd"}, -1
	);

	args::ValueFlagList<mem_region> dump_mem
	(
		parser, "addr,length", "Dump a memory region", {"dump-mem"}
	);

	args::ValueFlagList<mem_init> const_
	(
		parser, "addr,value", "Add a constant mapping", {"const"}
	);

	args::ValueFlagList<file_load> loads
	(
		parser, "addr,filename", "Load a file", {"load"}
	);

	args::Positional<std::string> image
	(
		parser, "image", "Executable image to run", args::Options::Required
	);

	args::Positional<std::string> coverage_out
	(
		parser, "coverage-out", "Coverage output file"
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

	FILE *ctrl = stdout;
	if(*control_fd != -1)
	{
		if((ctrl = fdopen(*control_fd, "r+")) == nullptr)
		{
			std::perror("fdopen()");
			return EXIT_FAILURE;
		}

		dup2(*control_fd, STDERR_FILENO);
	}

	Vconspiracion top;

#if VM_TRACE
	VerilatedVcdC trace;

	bool enable_trace = std::getenv("TRACE");
	if (enable_trace) {
		Verilated::traceEverOn(true);
		top.trace(&trace, 0);
		trace.open("trace.vcd");
	}
#else
	bool enable_trace = false;
#endif

	mem hps_ddr3(0x0000'0000, 512 << 20);
	jtag_uart ttyJ0(0x3000'0000);
	interval_timer timer(0x3002'0000);
	interrupt_controller intc(0x3007'0000);

	auto &irq_lines = intc.lines();
	irq_lines.jtaguart = &ttyJ0;
	irq_lines.timer = &timer;

	mem vram(0x3800'0000, 64 << 20);
	null vram_null(0x3800'0000, 64 << 20, 2);
	window vram_window(vram, 0x0000'0000);

	Vconspiracion_platform &plat = *top.conspiracion->plat;
	display<Vconspiracion_vga_domain> vga
	(
		*plat.vga, 0x3800'0000, 25'175'000, 50'000'000
	);

	interconnect<Vconspiracion_platform> avl(plat);
	//interconnect<Vconspiracion_vga_domain> avl_vga(plat->vga);

	std::vector<const_map> consts;
	for(const auto &init : *const_)
	{
		consts.emplace_back(init.addr, init.value);
	}

	bool enable_fast_video = !headless && !accurate_video;
	bool enable_accurate_video = !headless && accurate_video;

	avl.attach(hps_ddr3);
	avl.attach(timer);
	avl.attach(ttyJ0);
	avl.attach_intc(intc);

	for(auto &slave : consts)
	{
		avl.attach(slave);
	}

	if(enable_fast_video)
	{
		avl.attach(vga);
	} else if(enable_accurate_video)
	{
		avl.attach(vram);
		//avl_vga.attach(vram_window);
	} else
	{
		avl.attach(vram_null);
	}

	FILE *img_file = std::fopen(image->c_str(), "rb");
	if(!img_file)
	{
		std::fprintf(stderr, "fopen(\"%s\"): %m\n", image->c_str());
		return EXIT_FAILURE;
	}

	hps_ddr3.load([&](line *buffer, std::size_t lines)
	{
		return std::fread(buffer, sizeof *buffer, lines, img_file);
	});

	std::fclose(img_file);

	for(const auto &load : *loads)
	{
		FILE *img_file = std::fopen(load.filename.c_str(), "rb");
		if(!img_file)
		{
			std::fprintf(stderr, "fopen(\"%s\"): %m\n", load.filename.c_str());
			return EXIT_FAILURE;
		}

		hps_ddr3.load([&](line *buffer, std::size_t lines)
		{
			return std::fread(buffer, sizeof *buffer, lines, img_file);
		}, load.addr);

		std::fclose(img_file);
	}

	auto &core = *plat.cpu0->cpu;
	for(const auto &init : init_regs)
	{
		core.regs->a->file[init.index] = init.value;
		core.regs->b->file[init.index] = init.value;
	}

	int time = 0;
	top.clk_clk = 1;

	bool failed = false;

	auto tick = [&]()
	{
		top.clk_clk = !top.clk_clk;
		top.eval();

		if(!avl.tick(top.clk_clk))
		{
			failed = true;
		}

		if(enable_accurate_video)
		{
			/*if(!avl_vga.tick(top.clk_clk))
			{
				failed = true;
			}*/

			vga.signal_tick(top.clk_clk);
		}

#if VM_TRACE
		if(enable_trace)
		{
			trace.dump(time++);
		}
#endif
	};

	auto cycle = [&]()
	{
		tick();
		tick();
	};

	if(!no_tty)
	{
		ttyJ0.takeover();
	}

	top.step = 0;
	top.halt = start_halted;
	top.rst_n = 0;
	cycle();
	top.rst_n = 1;

	auto do_reg_dump = [&]()
	{
		std::fputs("=== dump-regs ===\n", ctrl);

		const auto &regfile = core.regs->a->file;

		int i = 0;
		for(const auto *name : gp_regs)
		{
			std::fprintf(ctrl, "%08x %s\n", regfile[i++], name);
		}

		std::fprintf(ctrl, "%08x pc\n", core.control->pc << 2);
		std::fprintf(ctrl, "%08x cpsr\n", core.psr->cpsr_word);
		std::fprintf(ctrl, "%08x spsr_svc\n", core.psr->spsr_svc_word);
		std::fprintf(ctrl, "%08x spsr_abt\n", core.psr->spsr_abt_word);
		std::fprintf(ctrl, "%08x spsr_und\n", core.psr->spsr_und_word);
		std::fprintf(ctrl, "%08x spsr_fiq\n", core.psr->spsr_fiq_word);
		std::fprintf(ctrl, "%08x spsr_irq\n", core.psr->spsr_irq_word);
		std::fprintf(ctrl, "%08x sysctrl\n", core.cp15->syscfg->ctrl);
		std::fprintf(ctrl, "%08x ttbr\n", core.cp15->ttbr->read);
		std::fprintf(ctrl, "%08x far\n", core.cp15->far_->read);
		std::fprintf(ctrl, "%08x fsr\n", core.cp15->fsr->read);
		std::fprintf(ctrl, "%08x dacr\n", core.cp15->domain->mmu_dac);
		std::fprintf(ctrl, "%08x bh0\n", core.control->ctrl_issue->bh0);
		std::fprintf(ctrl, "%08x bh1\n", core.control->ctrl_issue->bh1);
		std::fprintf(ctrl, "%08x bh2\n", core.control->ctrl_issue->bh2);
		std::fprintf(ctrl, "%08x bh3\n", core.control->ctrl_issue->bh3);
		std::fputs("=== end-regs ===\n", ctrl);
	};

	Vconspiracion_cache_sram *const caches[] = {
		plat.cache0->sram,
		plat.cache1->sram,
		plat.cache2->sram,
		plat.cache3->sram
	};

	auto dump_coherent = [&](std::uint32_t addr, std::uint32_t &data)
	{
		bool ok = avl.dump(addr, data);
		if (!ok || (ok >> 29))
			return ok;

		unsigned tag = (addr >> 11) & ((1 << 16) - 1);
		unsigned index = (addr >> 2) & ((1 << 9) - 1);

		for (std::size_t i = 0; i < sizeof caches / sizeof caches[0]; ++i) {
			const auto *cache = caches[i];

			if (cache->state_file[index] != 0b00 && cache->tag_file[index] == tag) {
				line line_data = cache->data_file[index];
				data = line_data.words[addr & 0b11];
			}
		}

		return true;
	};

	auto pagewalk = [&](std::uint32_t &addr)
	{
		if(!core.mmu->mmu_enable)
		{
			return true;
		}

		std::uint32_t ttbr = core.mmu->mmu_ttbr;

		std::uint32_t entry;
		if (!dump_coherent(ttbr << 12 | addr >> 18, entry))
			return false;

		switch (entry & 0b11) {
			case 0b01:
				break;

			case 0b10:
				addr = (entry & ~((1 << 20) - 1)) >> 2 | (addr & ((1 << 18) - 1));
				return true;

			default:
				return false;
		}

		std::uint32_t entryaddr = (entry & ~((1 << 10) - 1)) >> 2 | ((addr >> 10) & ((1 << 8) - 1));
		if (!dump_coherent(entryaddr, entry))
			return false;

		switch (entry & 0b11) {
			case 0b01:
				addr = (entry & ~((1 << 16) - 1)) >> 2 | (addr & ((1 << 14) - 1));
				return true;

			case 0b10:
			case 0b11:
				addr = (entry & ~((1 << 12) - 1)) >> 2 | (addr & ((1 << 10) - 1));
				return true;

			default:
				return false;
		}
	};

	auto do_mem_dump = [&](const mem_region *dumps, std::size_t count)
	{
		std::fputs("=== dump-mem ===\n", ctrl);
		for(std::size_t i = 0; i < count; ++i)
		{
			const auto &dump = dumps[i];

			std::fprintf(ctrl, "%08x ", static_cast<std::uint32_t>(dump.start));
			for(std::size_t i = 0; i < dump.length; ++i)
			{
				std::uint32_t at = dump.start + i;
				if(!pagewalk(at))
				{
					break;
				}

				std::uint32_t word;
				if (!dump_coherent(at, word))
					break;

				word = (word & 0xff) << 24
					 | ((word >> 8) & 0xff) << 16
					 | ((word >> 16) & 0xff) << 8
					 | ((word >> 24) & 0xff);

				std::fprintf(ctrl, "%08x", word);
			}

			std::fputc('\n', ctrl);
		}

		std::fputs("=== end-mem ===\n", ctrl);
	};

	std::signal(SIGUSR1, async_halt_handler);

	core.fetch->explicit_branch__VforceVal = 1;

	auto maybe_halt = [&]()
	{
		if(top.breakpoint || async_halt)
		{
			top.halt = 1;
		}

		return top.halt;
	};

	auto loop_fast = [&]()
	{
		do
		{
			for(unsigned iters = 0; iters < 1024 && !top.breakpoint; ++iters)
			{
				top.clk_clk = 0;
				top.eval();
				avl.tick_falling();

				top.clk_clk = 1;
				top.eval();

				// This is free most of the time
				try
				{
					avl.tick_rising();
				} catch(const avl_bus_error&)
				{
					failed = true;
					break;
				}
			}
		} while(!maybe_halt());
	};

	unsigned i = 0;
	auto loop_accurate = [&]()
	{
		do
		{
			cycle();
			maybe_halt();
		} while(!failed && !top.cpu_halted && (*cycles == 0 || ++i < *cycles));
	};

	const bool slow_path = *cycles > 0 || enable_accurate_video || enable_trace;

	while(true)
	{
		if(slow_path || top.halt || top.step)
		{
			loop_accurate();
		} else
		{
			loop_fast();
		}

		if(failed || (*cycles > 0 && i >= *cycles))
		{
			break;
		}

		top.step = 0;
		core.fetch->target__VforceVal = core.control->pc;

		do_reg_dump();
		std::fprintf(ctrl, "=== %s ===\n", failed ? "fault" : "halted");

		char *line = nullptr;
		std::size_t buf_size = 0;

		while(true)
		{
			ssize_t read = getline(&line, &buf_size, ctrl);
			if(read == -1)
			{
				if(!std::feof(ctrl))
				{
					std::perror("getline()");
					failed = true;
				}

				break;
			}

			if(read > 0 && line[read - 1] == '\n')
			{
				line[read - 1] = '\0';
			}

			const char *cmd = std::strtok(line, " ");
			if(!std::strcmp(cmd, "continue"))
			{
				break;
			} else if(!std::strcmp(cmd, "step"))
			{
				top.step = 1;
				break;
			} else if(!std::strcmp(cmd, "dump-mem"))
			{
				mem_region dump = {};
				std::sscanf(std::strtok(nullptr, " "), "%zu", &dump.start);
				std::sscanf(std::strtok(nullptr, " "), "%zu", &dump.length);
				do_mem_dump(&dump, 1);
			} else if(!std::strcmp(cmd, "patch-mem"))
			{
				std::uint32_t addr;
				std::sscanf(std::strtok(nullptr, " "), "%u", &addr);

				const char *data = std::strtok(nullptr, " ");
				std::size_t length = std::strlen(data);

				while(data && length >= 8)
				{
					std::uint32_t word;
					std::sscanf(data, "%08x", &word);

					data += 8;
					length -= 8;

					word = (word & 0xff) << 24
						 | ((word >> 8) & 0xff) << 16
						 | ((word >> 16) & 0xff) << 8
						 | ((word >> 24) & 0xff);

					std::uint32_t phys = addr++;
					if(!pagewalk(phys))
					{
						break;
					}

					avl.patch(phys, word);
				}
			} else if(!std::strcmp(cmd, "patch-reg"))
			{
				std::uint32_t value;
				std::sscanf(std::strtok(nullptr, " "), "%u", &value);

				const char *name = std::strtok(nullptr, " ");
				if(!std::strcmp(name, "pc"))
				{
					core.fetch->target__VforceVal = value >> 2;
				} else
				{
					std::size_t index = 0;
					for(const char *reg : gp_regs)
					{
						if(!strcmp(name, reg))
						{
							core.regs->a->file[index] = value;
							core.regs->b->file[index] = value;
							break;
						}

						++index;
					}
				}
			}
		}

		std::free(line);
		async_halt = 0;

		core.fetch->target__VforceEn = 0xffff'ffff;
		core.fetch->explicit_branch__VforceEn = 1;

		cycle();
		top.halt = 0;

		core.fetch->target__VforceEn = 0;
		core.fetch->explicit_branch__VforceEn = 0;
	}

	if (!no_tty)
		ttyJ0.release();

#if VM_TRACE
	if (enable_trace)
		trace.close();
#endif

	if (dump_regs)
		do_reg_dump();

	const auto &dumps = *dump_mem;
	if (!dumps.empty())
		do_mem_dump(dumps.data(), dumps.size());

	top.final();
	if (ctrl != stdout)
		std::fclose(ctrl);

#if VM_COVERAGE
	if (coverage_out)
		Verilated::threadContextp()->coveragep()->write(coverage_out->c_str());
#endif

	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
