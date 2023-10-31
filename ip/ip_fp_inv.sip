set_global_assignment -entity "ip_fp_inv" -library "lib_ip_fp_inv" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "ip_fp_inv" -library "lib_ip_fp_inv" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "ip_fp_inv" -library "lib_ip_fp_inv" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ip_fp_inv" -name SPD_FILE [file join $::quartus(sip_path) "ip_fp_inv.spd"]

set_global_assignment -library "lib_ip_fp_inv" -name MISC_FILE [file join $::quartus(sip_path) "ip_fp_inv_sim/ip_fp_inv.vo"]
