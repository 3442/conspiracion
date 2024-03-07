#include <iostream>
#include <cstddef>
#include <cstdio>
#include <cstdlib>

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

	float a, b;
	std::cin >> a >> b;

	// mul int
	//top.mul_float_m1 = 0;
	//top.unit_b_m1 = 0;
	//top.float_a_1 = 0;
	//top.int_hi_a_1 = 0;
	//top.int_lo_a_1 = 1;
	//top.zero_flags_a_1 = 1;
	//top.zero_b_1 = 1;
	//top.copy_flags_2 = 1;
	//top.copy_flags_5 = 1;
	//top.enable_norm_6 = 0;
	//top.copy_flags_10 = 1;
	//top.copy_flags_11 = 1;
	//top.enable_round_11 = 0;
	//top.encode_special_13 = 0;

	// mul fp
	//top.mul_float_m1 = 1;
	//top.unit_b_m1 = 0;
	//top.float_a_1 = 1;
	//top.int_hi_a_1 = 0;
	//top.int_lo_a_1 = 0;
	//top.zero_flags_a_1 = 0;
	//top.zero_b_1 = 1;
	//top.copy_flags_2 = 1;
	//top.copy_flags_5 = 1;
	//top.enable_norm_6 = 1;
	//top.copy_flags_10 = 1;
	//top.copy_flags_11 = 1;
	//top.enable_round_11 = 1;
	//top.encode_special_13 = 1;

	// suma/resta
	top.mul_float_m1 = 0;
	top.unit_b_m1 = 1;
	top.float_a_1 = 0;
	top.int_hi_a_1 = 0;
	top.int_lo_a_1 = 1;
	top.zero_flags_a_1 = 0;
	top.zero_b_1 = 0;
	top.copy_flags_2 = 0;
	top.copy_flags_5 = 0;
	top.enable_norm_6 = 1;
	top.copy_flags_10 = 0;
	top.copy_flags_11 = 0;
	top.enable_round_11 = 1;
	top.encode_special_13 = 1;

	top.a = *reinterpret_cast<unsigned*>(&a);
	top.b = *reinterpret_cast<unsigned*>(&b);

	for (int i = 0; i < 1000; ++i) {
		top.clk = 0;
		top.eval();

		top.clk = 1;
		top.eval();
	}

	unsigned q = top.q;
	std::cout << a << " * " << b << " = " << *reinterpret_cast<decltype(a)*>(&q) << '\n';

	bool failed = Py_FinalizeEx() < 0;

#if VM_TRACE
	trace.close();
#endif

	top.final();
	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
