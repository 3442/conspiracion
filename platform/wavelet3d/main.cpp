#include <iostream>
#include <cstddef>
#include <cstdio>
#include <cstdlib>
#include <string>

#include <Python.h>
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
	VerilatedFstC trace;
#endif

	Py_Initialize();

	int time = 0;

	auto cycle = [&]()
	{
		top.clk = 0;
		top.eval();

		top.clk = 1;
		top.eval();

		++time;
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

	top.rst_n = 0;
	top.in_valid = 0;
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

	while (time < 50) {
		cycle();

		if (!top.out_valid)
			continue;

		unsigned q_bits = top.q[0];
		int q_int = *reinterpret_cast<int*>(&q_bits);
		float q_flt = *reinterpret_cast<float*>(&q_bits);

		std::printf
		(
			"[%03d] => q=0x%08x, q_flt=%g, q_int=%d, q_uint=%u\n",
			time, q_bits, q_flt, q_int, q_bits
		);
	}

	bool failed = Py_FinalizeEx() < 0;

#if VM_TRACE
	trace.close();
#endif

	top.final();
	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
