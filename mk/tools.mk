define find_tools_lazy
  $(call find_command_lazy,cocotb-config,COCOTB_CONFIG)
  $(call find_command_lazy,genhtml,GENHTML)
  $(call find_command_lazy,meson,MESON)
  $(call find_command_lazy,ninja,NINJA)
  $(call find_command_lazy,peakrdl,PEAKRDL)
  $(call find_command_lazy,pkg-config,PKG_CONFIG)
  $(call find_command_lazy,pdoc3,PDOC3)
  $(call find_command_lazy,python3,PYTHON3)
  $(call find_command_lazy,qsys-generate,QSYS_GENERATE)
  $(call find_command_lazy,quartus,QUARTUS)
  $(call find_command_lazy,verilator,VERILATOR)

  $(call shell_defer,cocotb_share,$$(COCOTB_CONFIG) --share)
  $(call shell_defer,cocotb_libdir,$$(COCOTB_CONFIG) --lib-dir)
  $(call shell_defer,cocotb_libpython,$$(COCOTB_CONFIG) --libpython)
endef
