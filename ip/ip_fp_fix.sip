set_global_assignment -entity "ip_fp_fix" -library "lib_ip_fp_fix" -name IP_TOOL_NAME "altera_fp_functions"
set_global_assignment -entity "ip_fp_fix" -library "lib_ip_fp_fix" -name IP_TOOL_VERSION "20.1"
set_global_assignment -entity "ip_fp_fix" -library "lib_ip_fp_fix" -name IP_TOOL_ENV "mwpim"
set_global_assignment -library "lib_ip_fp_fix" -name SPD_FILE [file join $::quartus(sip_path) "ip_fp_fix.spd"]

set_global_assignment -library "lib_ip_fp_fix" -name MISC_FILE [file join $::quartus(sip_path) "ip_fp_fix_sim/ip_fp_fix.vo"]
