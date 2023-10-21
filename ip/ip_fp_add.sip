set_global_assignment -entity "ip_fp_add" -library "lib_ip_fp_add" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "ip_fp_add" -library "lib_ip_fp_add" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "ip_fp_add" -library "lib_ip_fp_add" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ip_fp_add" -name SPD_FILE [file join $::quartus(sip_path) "ip_fp_add.spd"]

set_global_assignment -library "lib_ip_fp_add" -name MISC_FILE [file join $::quartus(sip_path) "ip_fp_add_sim/ip_fp_add.vo"]
