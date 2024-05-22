# TCL File Generated by Component Editor 20.1
# Thu Dec 15 09:41:45 GMT 2022
# DO NOT MODIFY


# 
# intc "Interrupt controller" v1.0
#  2022.12.15.09:41:45
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module intc
# 
set_module_property DESCRIPTION ""
set_module_property NAME intc
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Interrupt controller"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL intc
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file intc.sv SYSTEM_VERILOG PATH intc.sv TOP_LEVEL_FILE


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock_sink
# 
add_interface clock_sink clock end
set_interface_property clock_sink clockRate 0
set_interface_property clock_sink ENABLED true
set_interface_property clock_sink EXPORT_OF ""
set_interface_property clock_sink PORT_NAME_MAP ""
set_interface_property clock_sink CMSIS_SVD_VARIABLES ""
set_interface_property clock_sink SVD_ADDRESS_GROUP ""

add_interface_port clock_sink clk clk Input 1


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock_sink
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink rst_n reset_n Input 1


# 
# connection point avalon_slave
# 
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock_sink
set_interface_property avalon_slave associatedReset reset_sink
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave burstOnBurstBoundariesOnly false
set_interface_property avalon_slave burstcountUnits WORDS
set_interface_property avalon_slave explicitAddressSpan 0
set_interface_property avalon_slave holdTime 0
set_interface_property avalon_slave linewrapBursts false
set_interface_property avalon_slave maximumPendingReadTransactions 0
set_interface_property avalon_slave maximumPendingWriteTransactions 0
set_interface_property avalon_slave readLatency 0
set_interface_property avalon_slave readWaitTime 1
set_interface_property avalon_slave setupTime 0
set_interface_property avalon_slave timingUnits Cycles
set_interface_property avalon_slave writeWaitTime 0
set_interface_property avalon_slave ENABLED true
set_interface_property avalon_slave EXPORT_OF ""
set_interface_property avalon_slave PORT_NAME_MAP ""
set_interface_property avalon_slave CMSIS_SVD_VARIABLES ""
set_interface_property avalon_slave SVD_ADDRESS_GROUP ""

add_interface_port avalon_slave avl_address address Input 1
add_interface_port avalon_slave avl_read read Input 1
add_interface_port avalon_slave avl_write write Input 1
add_interface_port avalon_slave avl_readdata readdata Output 32
add_interface_port avalon_slave avl_writedata writedata Input 32
set_interface_assignment avalon_slave embeddedsw.configuration.isFlash 0
set_interface_assignment avalon_slave embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment avalon_slave embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment avalon_slave embeddedsw.configuration.isPrintableDevice 0


# 
# connection point interrupt_sender
# 
add_interface interrupt_sender interrupt end
set_interface_property interrupt_sender associatedAddressablePoint avalon_slave
set_interface_property interrupt_sender associatedClock clock_sink
set_interface_property interrupt_sender bridgedReceiverOffset ""
set_interface_property interrupt_sender bridgesToReceiver ""
set_interface_property interrupt_sender ENABLED true
set_interface_property interrupt_sender EXPORT_OF ""
set_interface_property interrupt_sender PORT_NAME_MAP ""
set_interface_property interrupt_sender CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_sender SVD_ADDRESS_GROUP ""

add_interface_port interrupt_sender avl_irq irq Output 1


# 
# connection point interrupt_timer
# 
add_interface interrupt_timer interrupt start
set_interface_property interrupt_timer associatedAddressablePoint ""
set_interface_property interrupt_timer associatedClock clock_sink
set_interface_property interrupt_timer irqScheme INDIVIDUAL_REQUESTS
set_interface_property interrupt_timer ENABLED true
set_interface_property interrupt_timer EXPORT_OF ""
set_interface_property interrupt_timer PORT_NAME_MAP ""
set_interface_property interrupt_timer CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_timer SVD_ADDRESS_GROUP ""

add_interface_port interrupt_timer irq_timer irq Input 1


# 
# connection point interrupt_jtaguart
# 
add_interface interrupt_jtaguart interrupt start
set_interface_property interrupt_jtaguart associatedAddressablePoint ""
set_interface_property interrupt_jtaguart associatedClock clock_sink
set_interface_property interrupt_jtaguart irqScheme INDIVIDUAL_REQUESTS
set_interface_property interrupt_jtaguart ENABLED true
set_interface_property interrupt_jtaguart EXPORT_OF ""
set_interface_property interrupt_jtaguart PORT_NAME_MAP ""
set_interface_property interrupt_jtaguart CMSIS_SVD_VARIABLES ""
set_interface_property interrupt_jtaguart SVD_ADDRESS_GROUP ""

add_interface_port interrupt_jtaguart irq_jtaguart irq Input 1
