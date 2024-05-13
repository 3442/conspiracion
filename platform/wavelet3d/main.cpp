#include <queue>
#include <cmath>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <iostream>
#include <memory>
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
	auto top = std::make_unique<Vtop>();

#if VM_TRACE
	Verilated::traceEverOn(true);

	auto trace = std::make_unique<VerilatedFstC>();
	top->trace(&*trace, 0);
	trace->open("dump.fst");
#endif

	int time = 0;

	auto cycle = [&]()
	{
		top->eval();
#if VM_TRACE
		trace->dump(time++);
#endif
		top->clk = 1;

		top->eval();
#if VM_TRACE
		trace->dump(time++);
#endif
		top->clk = 0;
	};

	top->clk = 0;
	top->rst_n = 0;

	top->dram_bresp = 0;
	top->dram_rresp = 0;
	top->dram_bvalid = 0;
	top->dram_rvalid = 0;
	top->dram_wready = 0;
	top->dram_arready = 0;
	top->dram_awready = 0;

	top->jtag_tck = 0;
	top->jtag_tms = 0;
	top->jtag_tdi = 0;

	cycle();

	top->rst_n = 1;
	cycle();

	rbs_init(1234);

	struct a_req
	{
		unsigned id, addr, len;
	};

	struct w_req
	{
		bool last;
		unsigned data, strb;
	};

	std::queue<a_req> ar_queue, aw_queue;
	std::queue<w_req> w_queue;

	constexpr std::size_t MAX_PENDING    = 8;
	constexpr std::size_t DRAM_SIZE      = (512 << 20) >> 2;
	constexpr std::size_t FLASH_BOUNDARY = (64 << 20) >> 2;

	auto dram = std::make_unique<unsigned[]>(DRAM_SIZE);

	constexpr const char *FLASH_IMG_FILE = "host_flash.bin";

	FILE *flash_img = std::fopen(FLASH_IMG_FILE, "rb");
	if (!flash_img) {
		fprintf(stderr, "fopen(\"%s\"): %m\n", FLASH_IMG_FILE);
		return EXIT_FAILURE;
	}

	std::fseek(flash_img, 0, SEEK_END);
	auto img_size = std::ftell(flash_img);
	std::fseek(flash_img, 0, SEEK_SET);

	if (img_size <= 0) {
		img_size = 0;
		fprintf(stderr, "%s: file is empty or seek failed: %m\n", FLASH_IMG_FILE);
	} else if (img_size > FLASH_BOUNDARY * 4) {
		img_size = FLASH_BOUNDARY * 4;
		fprintf(stderr, "%s: too large, truncated to %ld bytes\n", FLASH_IMG_FILE, img_size);
	}

	auto *read_base = reinterpret_cast<unsigned char*>(&dram[0]);
	while (img_size > 0) {
		auto read = std::fread(read_base, 1, img_size, flash_img);

		img_size -= read;
		read_base += read;
	}

	fclose(flash_img);

	do {
		cycle();

		//FIXME: para respetar AXI hay que top->eval()'ear luedo de levantar valid

		top->dram_rvalid = 0;
		if (!ar_queue.empty()) {
			auto &ar = ar_queue.front();

			top->dram_rid = ar.id;
			top->dram_rlast = ar.len == 0;
			top->dram_rvalid = 1;

			auto index = ar.addr >> 2;
			if (index >= DRAM_SIZE) [[unlikely]] {
				fprintf(stderr, "Bad DRAM read address: %08x\n", ar.addr);
				top->dram_rdata = 0;
			} else
				top->dram_rdata = dram[index];

			if (top->dram_rvalid && top->dram_rready) {
				ar.addr += 4;
				--ar.len;

				if (top->dram_rlast)
					ar_queue.pop();
			}
		}

		top->dram_bvalid = 0;
		if (!aw_queue.empty() && !w_queue.empty()) {
			auto &w = w_queue.front();
			auto &aw = aw_queue.front();

			auto index = aw.addr >> 2;
			if (index >= DRAM_SIZE) [[unlikely]]
				fprintf(stderr, "Bad DRAM write address: %08x\n", aw.addr);
			else if (index < FLASH_BOUNDARY) [[unlikely]]
				fprintf(stderr, "Attempt to write to flash: %08x\n", aw.addr);
			else {
				constexpr unsigned STRB_MASKS[16] = {
					[0b0000] = 0x00000000,
					[0b0001] = 0x000000ff,
					[0b0010] = 0x0000ff00,
					[0b0011] = 0x0000ffff,
					[0b0100] = 0x00ff0000,
					[0b0101] = 0x00ff00ff,
					[0b0110] = 0x00ffff00,
					[0b0111] = 0x00ffffff,
					[0b1000] = 0xff000000,
					[0b1001] = 0xff0000ff,
					[0b1010] = 0xff00ff00,
					[0b1011] = 0xff00ffff,
					[0b1100] = 0xffff0000,
					[0b1101] = 0xffff00ff,
					[0b1110] = 0xffffff00,
					[0b1111] = 0xffffffff,
				};

				unsigned mask = STRB_MASKS[w.strb & 0b1111];
				dram[index] = (w.data & mask) | (dram[index] & ~mask);
			}

			top->dram_bid = aw.id;
			top->dram_bvalid = w.last;

			if (!top->dram_bvalid || top->dram_bready) {
				w_queue.pop();
				aw.addr += 4;
			}

			if (top->dram_bvalid && top->dram_bready)
				aw_queue.pop();
		}

		top->dram_arready = ar_queue.size() < MAX_PENDING;
		if (top->dram_arready && top->dram_arvalid)
			ar_queue.push({
				.id = top->dram_arid,
				.addr = top->dram_araddr,
				.len = top->dram_arlen,
			});

		top->dram_awready = aw_queue.size() < MAX_PENDING;
		if (top->dram_awready && top->dram_awvalid)
			aw_queue.push({
				.id = top->dram_awid,
				.addr = top->dram_awaddr,
				.len = top->dram_awlen,
			});

		top->dram_wready = w_queue.size() < MAX_PENDING;
		if (top->dram_wready && top->dram_wvalid)
			w_queue.push({
				.last = !!top->dram_wlast,
				.data = top->dram_wdata,
				.strb = top->dram_wstrb,
			});

		unsigned char tck = top->jtag_tck;
		unsigned char tms = top->jtag_tms;
		unsigned char tdi = top->jtag_tdi;
		unsigned char trstn = 1;

		rbs_tick(&tck, &tms, &tdi, &trstn, top->jtag_tdo);

		top->jtag_tck = tck;
		top->jtag_tms = tms;
		top->jtag_tdi = tdi;
	} while (!(client_fd < 0));

#if VM_TRACE
	trace->close();
#endif

	top->final();

	return EXIT_SUCCESS;
}
