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

	auto send_op = [&](auto a, const char *op, auto b)
	{
		std::printf
		(
			"[%03d] <= %s %s %s\n",
			time, std::to_string(a).c_str(), op, std::to_string(b).c_str()
		);

		top.a[0] = *reinterpret_cast<unsigned*>(&a);
		top.b[0] = *reinterpret_cast<unsigned*>(&b);
		top.in_valid = 1;
		cycle();

		top.a[0] = 0;
		top.b[0] = 0;
		top.in_valid = 0;
	};

	auto int_to_fp = [&](int a)
	{
		top.setup_mul_float = 0;
		top.setup_unit_b = 1;
		top.mnorm_put_hi = 0;
		top.mnorm_put_lo = 1;
		top.mnorm_put_mul = 0;
		top.mnorm_zero_flags = 1;
		top.mnorm_zero_b = 1;
		top.minmax_abs = 1;
		top.minmax_swap = 0;
		top.minmax_zero_min = 0;
		top.minmax_copy_flags = 0;
		top.shiftr_int_signed = 1;
		top.addsub_int_operand = 1;
		top.addsub_copy_flags = 1;
		top.clz_force_nop = 0;
		top.shiftl_copy_flags = 0;
		top.round_copy_flags = 0;
		top.round_enable = 1;
		top.encode_enable = 1;

		send_op(a, "fp->int", 0);
	};

	auto mul_int = [&](unsigned a, unsigned b)
	{
		top.setup_mul_float = 0;
		top.setup_unit_b = 0;
		top.mnorm_put_hi = 0;
		top.mnorm_put_lo = 1;
		top.mnorm_put_mul = 0;
		top.mnorm_zero_flags = 1;
		top.mnorm_zero_b = 1;
		top.minmax_abs = 1;
		top.minmax_swap = 0;
		top.minmax_zero_min = 0;
		top.minmax_copy_flags = 1;
		top.shiftr_int_signed = 0;
		top.addsub_int_operand = 0;
		top.addsub_copy_flags = 1;
		top.clz_force_nop = 1;
		top.shiftl_copy_flags = 1;
		top.round_copy_flags = 1;
		top.round_enable = 0;
		top.encode_enable = 0;

		send_op(a, "*", b);
	};

	// mul fp
	auto mul_fp = [&](float a, float b)
	{
		top.setup_mul_float = 1;
		top.setup_unit_b = 0;
		top.mnorm_put_hi = 0;
		top.mnorm_put_lo = 0;
		top.mnorm_put_mul = 1;
		top.mnorm_zero_flags = 0;
		top.mnorm_zero_b = 1;
		top.minmax_abs = 1;
		top.minmax_swap = 0;
		top.minmax_zero_min = 0;
		top.minmax_copy_flags = 1;
		top.shiftr_int_signed = 0;
		top.addsub_int_operand = 0;
		top.addsub_copy_flags = 1;
		top.clz_force_nop = 1;
		top.shiftl_copy_flags = 1;
		top.round_copy_flags = 1;
		top.round_enable = 1;
		top.encode_enable = 1;

		send_op(a, "*", b);
	};

	auto add_fp = [&](float a, float b)
	{
		top.setup_mul_float = 0;
		top.setup_unit_b = 1;
		top.mnorm_put_hi = 0;
		top.mnorm_put_lo = 1;
		top.mnorm_put_mul = 0;
		top.mnorm_zero_flags = 0;
		top.mnorm_zero_b = 0;
		top.minmax_abs = 1;
		top.minmax_swap = 0;
		top.minmax_zero_min = 0;
		top.minmax_copy_flags = 0;
		top.shiftr_int_signed = 0;
		top.addsub_int_operand = 0;
		top.addsub_copy_flags = 0;
		top.clz_force_nop = 0;
		top.shiftl_copy_flags = 0;
		top.round_copy_flags = 0;
		top.round_enable = 1;
		top.encode_enable = 1;

		send_op(a, "+", b);
	};

	auto min_max_fp = [&](float a, float b, bool min = false)
	{
		top.setup_mul_float = 0;
		top.setup_unit_b = 1;
		top.mnorm_put_hi = 0;
		top.mnorm_put_lo = 1;
		top.mnorm_put_mul = 0;
		top.mnorm_zero_flags = 0;
		top.mnorm_zero_b = 0;
		top.minmax_abs = 0;
		top.minmax_swap = min;
		top.minmax_zero_min = 1;
		top.minmax_copy_flags = 1;
		top.shiftr_int_signed = 0;
		top.addsub_int_operand = 0;
		top.addsub_copy_flags = 1;
		top.clz_force_nop = 1;
		top.shiftl_copy_flags = 1;
		top.round_copy_flags = 1;
		top.round_enable = 0;
		top.encode_enable = 0;

		send_op(a, min ? "min" : "max", b);
	};

	top.clk = 0;
	top.rst_n = 0;
	top.in_valid = 0;
	top.geom_tvalid = 0;
	top.raster_tready = 0;
	cycle();

	top.rst_n = 1;
	cycle();

	int a, b;
	float a_flt, b_flt;

	std::cout << "a_int: ";
	std::cin >> a;
	std::cout << "b_int: ";
	std::cin >> b;
	std::cout << "a_flt: ";
	std::cin >> a_flt;
	std::cout << "b_flt: ";
	std::cin >> b_flt;

	int_to_fp(a);
	mul_int(a, b);
	mul_fp(a_flt, b_flt);
	add_fp(a_flt, b_flt);
	min_max_fp(a_flt, b_flt);
	min_max_fp(a_flt, b_flt, true);

	float a_x, a_y, b_x, b_y, c_x, c_y;
	std::cout << "a_x: ";
	std::cin >> a_x;
	std::cout << "a_y: ";
	std::cin >> a_y;
	std::cout << "b_x: ";
	std::cin >> b_x;
	std::cout << "b_y: ";
	std::cin >> b_y;
	std::cout << "c_x: ";
	std::cin >> c_x;
	std::cout << "c_y: ";
	std::cin >> c_y;

	unsigned cycles;
	std::cout << "cycles: ";
	std::cin >> cycles;

	constexpr int FIXED_FRAC = 10;

	int geom[] = {
		42,
		static_cast<int>(::ldexpf(a_x, FIXED_FRAC)),
		static_cast<int>(::ldexpf(b_x, FIXED_FRAC)),
		static_cast<int>(::ldexpf(c_x, FIXED_FRAC)),
		static_cast<int>(::ldexpf(a_y, FIXED_FRAC)),
		static_cast<int>(::ldexpf(b_y, FIXED_FRAC)),
		static_cast<int>(::ldexpf(c_y, FIXED_FRAC)),
	};

    ::SDL_Event event;
    ::SDL_Renderer *renderer;
	::SDL_Window *window;

	//FIXME: errores
	::SDL_Init(SDL_INIT_VIDEO);
	::SDL_CreateWindowAndRenderer(640, 480, 0, &window, &renderer);
    ::SDL_SetRenderDrawColor(renderer, 0, 0, 0, 0);
	::SDL_RenderClear(renderer);

    ::SDL_SetRenderDrawColor(renderer, 255, 255, 255, 0);

	int bary_idx = 0, x_coarse, y_coarse, x_fine, y_fine;
	int geom_state = 0;
	int bit;
	float barys[3];
	unsigned mask;
	unsigned geom_idx = 0;

	top.raster_tready = 1;
	while (time < 2 * cycles) {
		cycle();

		if (top.out_valid) {
			unsigned q_bits = top.q[0];
			int q_int = *reinterpret_cast<int*>(&q_bits);
			float q_flt = *reinterpret_cast<float*>(&q_bits);

			std::printf
			(
				"[%03d] => q=0x%08x, q_flt=%g, q_int=%d, q_uint=%u\n",
				time, q_bits, q_flt, q_int, q_bits
			);
		}

		if (geom_idx < sizeof geom / sizeof geom[0]) {
			top.geom_tdata = geom[geom_idx];
			top.geom_tlast = geom_idx == sizeof geom / sizeof geom[0] - 1;
			top.geom_tvalid = 1;

			top.eval();
			if (top.geom_tready)
				geom_idx++;
		} else {
			top.geom_tlast = 0;
			top.geom_tvalid = 0;
		}

		if (top.raster_tvalid) {
			unsigned data = top.raster_tdata;
			auto fixed = ::ldexpf(static_cast<float>(static_cast<int>(data)), -FIXED_FRAC);

			//std::printf("[%03d] raster[%c] d=0x%08x, d_fix=%g\n",
			//	time, top.raster_tlast ? 'l' : '-', data, fixed);

			switch (geom_state) {
				case 0:
					geom_state = 1;
					break;

				case 1:
					y_coarse = (static_cast<int>(data) >> 16 << 2) + 480/2;
					x_coarse = (static_cast<short>(data & 0xffff) << 2) + 640/2;
					geom_state = 2;
    				::SDL_SetRenderDrawColor(renderer, 255, 0, 0, 0);
					for (int dy = 0; dy < 4; ++dy)
						for (int dx = 0; dx < 4; ++dx)
							::SDL_RenderDrawPoint(renderer, x_coarse + dx, y_coarse + dy);
					break;

				case 2:
					mask = data;
					geom_state = 3;
					break;

				case 3:
					bit = ::ffs(mask) - 1;
					barys[bary_idx] = fixed;
					switch (bary_idx) {
						case 0:
							bary_idx = 1;
							break;
						case 1:
							bary_idx = 2;
							break;
						case 2:
							bary_idx = 0;
							mask = mask & ~(1 << bit);
							y_fine = y_coarse + (bit >> 2);
							x_fine = x_coarse + (bit & 0b11);

    						::SDL_SetRenderDrawColor(renderer, 255, 255, 255, 0);
							::SDL_RenderDrawPoint(renderer, x_fine, y_fine);

							break;
					}
					if (top.raster_tlast)
						geom_state = 0;
					break;
			}
		}
	}

#if VM_TRACE
	trace.close();
#endif

	top.final();

	::SDL_RenderPresent(renderer);
    while (!::SDL_PollEvent(&event) || event.type != SDL_QUIT)
		continue;

	::SDL_DestroyRenderer(renderer);
	::SDL_DestroyWindow(window);
	::SDL_Quit();

	return EXIT_SUCCESS;
}
