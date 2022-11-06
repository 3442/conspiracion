set_global_assignment -entity "dsp_mul" -library "lib_dsp_mul" -name IP_TOOL_NAME "altera_mult_add"
set_global_assignment -entity "dsp_mul" -library "lib_dsp_mul" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "dsp_mul" -library "lib_dsp_mul" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_dsp_mul" -name SPD_FILE [file join $::quartus(sip_path) "dsp_mul.spd"]

set_global_assignment -library "lib_dsp_mul" -name MISC_FILE [file join $::quartus(sip_path) "dsp_mul_sim/dsp_mul.v"]
