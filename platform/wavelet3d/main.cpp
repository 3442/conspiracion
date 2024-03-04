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

	top.a = *reinterpret_cast<unsigned*>(&a);
	top.b = *reinterpret_cast<unsigned*>(&b);

	for (int i = 0; i < 1000; ++i) {
		top.clk = 0;
		top.eval();

		top.clk = 1;
		top.eval();
	}

	unsigned q = top.q;
	std::cout << a << " * " << b << " = " << *reinterpret_cast<float*>(&q) << '\n';

	bool failed = Py_FinalizeEx() < 0;

#if VM_TRACE
	trace.close();
#endif

	top.final();
	return failed ? EXIT_FAILURE : EXIT_SUCCESS;
}
