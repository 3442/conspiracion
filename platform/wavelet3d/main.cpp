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

	float q;
	int a, b;
	const char *op = "int->fp";

	std::cin >> a >> b;

	// int->fp
	top.setup_mul_float = 0;
	top.setup_unit_b = 1;
	top.mnorm_put_hi = 0;
	top.mnorm_put_lo = 1;
	top.mnorm_put_mul = 0;
	top.mnorm_zero_flags = 1;
	top.mnorm_zero_b = 1;
	top.minmax_copy_flags = 0;
	top.shiftr_int_signed = 1;
	top.addsub_int_operand = 1;
	top.addsub_copy_flags = 1;
	top.clz_force_nop = 1;
	top.shiftl_copy_flags = 0;
	top.round_copy_flags = 0;
	top.round_enable = 1;
	top.encode_enable = 1;

	// mul int
	//top.setup_mul_float = 0;
	//top.setup_unit_b = 0;
	//top.mnorm_put_hi = 0;
	//top.mnorm_put_lo = 1;
	//top.mnorm_put_mul = 0;
	//top.mnorm_zero_flags = 1;
	//top.mnorm_zero_b = 1;
	//top.minmax_copy_flags = 1;
	//top.shiftr_int_signed = 0;
	//top.addsub_int_operand = 0;
	//top.addsub_copy_flags = 1;
	//top.clz_force_nop = 0;
	//top.shiftl_copy_flags = 1;
	//top.round_copy_flags = 1;
	//top.round_enable = 0;
	//top.encode_enable = 0;

	// mul fp
	//top.setup_mul_float = 1;
	//top.setup_unit_b = 0;
	//top.mnorm_put_hi = 0;
	//top.mnorm_put_lo = 0;
	//top.mnorm_put_mul = 1;
	//top.mnorm_zero_flags = 0;
	//top.mnorm_zero_b = 1;
	//top.minmax_copy_flags = 1;
	//top.shiftr_int_signed = 0;
	//top.addsub_int_operand = 0;
	//top.addsub_copy_flags = 1;
	//top.clz_force_nop = 1;
	//top.shiftl_copy_flags = 1;
	//top.round_copy_flags = 1;
	//top.round_enable = 1;
	//top.encode_enable = 1;

	// suma/resta
	//top.setup_mul_float = 0;
	//top.setup_unit_b = 1;
	//top.mnorm_put_hi = 0;
	//top.mnorm_put_lo = 1;
	//top.mnorm_put_mul = 0;
	//top.mnorm_zero_flags = 0;
	//top.mnorm_zero_b = 0;
	//top.minmax_copy_flags = 0;
	//top.shiftr_int_signed = 0;
	//top.addsub_int_operand = 0;
	//top.addsub_copy_flags = 0;
	//top.clz_force_nop = 1;
	//top.shiftl_copy_flags = 0;
	//top.round_copy_flags = 0;
	//top.round_enable = 1;
	//top.encode_enable = 1;

	top.a = *reinterpret_cast<unsigned*>(&a);
	top.b = *reinterpret_cast<unsigned*>(&b);

	for (int i = 0; i < 1000; ++i) {
		top.clk = 0;
		top.eval();

		top.clk = 1;
		top.eval();
	}

	unsigned q_bits = top.q;
	q = *reinterpret_cast<decltype(q)*>(&q_bits);

	std::cout << a << ' ' << op << ' ' << b << " = " << q << '\n';

	bool failed = Py_FinalizeEx() < 0;

#if VM_TRACE
	trace.close();
#endif

	top.final();
	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
