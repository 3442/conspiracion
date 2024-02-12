cores := conspiracion/tb

define core/conspiracion/tb
  $(this)/deps         := cache core perf smp interconnect
  $(this)/rtl_files    := platform.sv sim_slave.sv vga_domain.sv
  $(this)/vl_files     := interrupt.cpp interval_timer.cpp jtag_uart.cpp mem.cpp sim_slave.cpp
  $(this)/vl_pkgconfig := ncursesw sdl2
endef
