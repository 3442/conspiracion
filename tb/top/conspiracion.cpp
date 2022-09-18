#include <verilated.h>
#include <cstdio>

#include "Vconspiracion.h"

int main(int argc, char **argv)
{
    Verilated::commandArgs(argc, argv);   // Remember args
	Verilated::traceEverOn(true);

	Vconspiracion top;
    // Do not instead make Vtop as a file-scope static
    // variable, as the "C++ static initialization order fiasco"
    // may cause a crash

	top.eval();

    top.final();
}
