# TCL File Generated by Component Editor 20.1
# Fri Oct 06 02:09:26 GMT 2023
# DO NOT MODIFY


# 
# perf "Performance monitor unit" v1.0
#  2023.10.06.02:09:26
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module perf
# 
set_module_property DESCRIPTION ""
set_module_property NAME perf
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "Performance monitor unit"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL perf_monitor
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file perf_monitor.sv SYSTEM_VERILOG PATH rtl/perf/perf_monitor.sv TOP_LEVEL_FILE
add_fileset_file perf_link.sv SYSTEM_VERILOG PATH rtl/perf/perf_link.sv
add_fileset_file perf_snoop.sv SYSTEM_VERILOG PATH rtl/perf/perf_snoop.sv


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
# connection point perf
# 
add_interface perf avalon end
set_interface_property perf addressUnits WORDS
set_interface_property perf associatedClock clock_sink
set_interface_property perf associatedReset reset_sink
set_interface_property perf bitsPerSymbol 8
set_interface_property perf burstOnBurstBoundariesOnly false
set_interface_property perf burstcountUnits WORDS
set_interface_property perf explicitAddressSpan 0
set_interface_property perf holdTime 0
set_interface_property perf linewrapBursts false
set_interface_property perf maximumPendingReadTransactions 0
set_interface_property perf maximumPendingWriteTransactions 0
set_interface_property perf readLatency 0
set_interface_property perf readWaitTime 1
set_interface_property perf setupTime 0
set_interface_property perf timingUnits Cycles
set_interface_property perf writeWaitTime 0
set_interface_property perf ENABLED true
set_interface_property perf EXPORT_OF ""
set_interface_property perf PORT_NAME_MAP ""
set_interface_property perf CMSIS_SVD_VARIABLES ""
set_interface_property perf SVD_ADDRESS_GROUP ""

add_interface_port perf perf_address address Input 6
add_interface_port perf perf_read read Input 1
add_interface_port perf perf_write write Input 1
add_interface_port perf perf_readdata readdata Output 32
add_interface_port perf perf_writedata writedata Input 32
set_interface_assignment perf embeddedsw.configuration.isFlash 0
set_interface_assignment perf embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment perf embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment perf embeddedsw.configuration.isPrintableDevice 0


# 
# connection point in_0
# 
add_interface in_0 avalon_streaming end
set_interface_property in_0 associatedClock clock_sink
set_interface_property in_0 associatedReset reset_sink
set_interface_property in_0 dataBitsPerSymbol 8
set_interface_property in_0 errorDescriptor ""
set_interface_property in_0 firstSymbolInHighOrderBits true
set_interface_property in_0 maxChannel 0
set_interface_property in_0 readyLatency 0
set_interface_property in_0 ENABLED true
set_interface_property in_0 EXPORT_OF ""
set_interface_property in_0 PORT_NAME_MAP ""
set_interface_property in_0 CMSIS_SVD_VARIABLES ""
set_interface_property in_0 SVD_ADDRESS_GROUP ""

add_interface_port in_0 in_0 data Input 160
add_interface_port in_0 in_0_ready ready Output 1
add_interface_port in_0 in_0_valid valid Input 1


# 
# connection point in_1
# 
add_interface in_1 avalon_streaming end
set_interface_property in_1 associatedClock clock_sink
set_interface_property in_1 associatedReset reset_sink
set_interface_property in_1 dataBitsPerSymbol 8
set_interface_property in_1 errorDescriptor ""
set_interface_property in_1 firstSymbolInHighOrderBits true
set_interface_property in_1 maxChannel 0
set_interface_property in_1 readyLatency 0
set_interface_property in_1 ENABLED true
set_interface_property in_1 EXPORT_OF ""
set_interface_property in_1 PORT_NAME_MAP ""
set_interface_property in_1 CMSIS_SVD_VARIABLES ""
set_interface_property in_1 SVD_ADDRESS_GROUP ""

add_interface_port in_1 in_1 data Input 160
add_interface_port in_1 in_1_ready ready Output 1
add_interface_port in_1 in_1_valid valid Input 1


# 
# connection point in_2
# 
add_interface in_2 avalon_streaming end
set_interface_property in_2 associatedClock clock_sink
set_interface_property in_2 associatedReset reset_sink
set_interface_property in_2 dataBitsPerSymbol 8
set_interface_property in_2 errorDescriptor ""
set_interface_property in_2 firstSymbolInHighOrderBits true
set_interface_property in_2 maxChannel 0
set_interface_property in_2 readyLatency 0
set_interface_property in_2 ENABLED true
set_interface_property in_2 EXPORT_OF ""
set_interface_property in_2 PORT_NAME_MAP ""
set_interface_property in_2 CMSIS_SVD_VARIABLES ""
set_interface_property in_2 SVD_ADDRESS_GROUP ""

add_interface_port in_2 in_2 data Input 160
add_interface_port in_2 in_2_ready ready Output 1
add_interface_port in_2 in_2_valid valid Input 1


# 
# connection point in_3
# 
add_interface in_3 avalon_streaming end
set_interface_property in_3 associatedClock clock_sink
set_interface_property in_3 associatedReset reset_sink
set_interface_property in_3 dataBitsPerSymbol 8
set_interface_property in_3 errorDescriptor ""
set_interface_property in_3 firstSymbolInHighOrderBits true
set_interface_property in_3 maxChannel 0
set_interface_property in_3 readyLatency 0
set_interface_property in_3 ENABLED true
set_interface_property in_3 EXPORT_OF ""
set_interface_property in_3 PORT_NAME_MAP ""
set_interface_property in_3 CMSIS_SVD_VARIABLES ""
set_interface_property in_3 SVD_ADDRESS_GROUP ""

add_interface_port in_3 in_3 data Input 160
add_interface_port in_3 in_3_ready ready Output 1
add_interface_port in_3 in_3_valid valid Input 1


# 
# connection point out_0
# 
add_interface out_0 avalon_streaming start
set_interface_property out_0 associatedClock clock_sink
set_interface_property out_0 associatedReset reset_sink
set_interface_property out_0 dataBitsPerSymbol 8
set_interface_property out_0 errorDescriptor ""
set_interface_property out_0 firstSymbolInHighOrderBits true
set_interface_property out_0 maxChannel 0
set_interface_property out_0 readyLatency 0
set_interface_property out_0 ENABLED true
set_interface_property out_0 EXPORT_OF ""
set_interface_property out_0 PORT_NAME_MAP ""
set_interface_property out_0 CMSIS_SVD_VARIABLES ""
set_interface_property out_0 SVD_ADDRESS_GROUP ""

add_interface_port out_0 out_0_ready ready Input 1
add_interface_port out_0 out_0_valid valid Output 1
add_interface_port out_0 out_0 data Output 160


# 
# connection point out_1
# 
add_interface out_1 avalon_streaming start
set_interface_property out_1 associatedClock clock_sink
set_interface_property out_1 associatedReset reset_sink
set_interface_property out_1 dataBitsPerSymbol 8
set_interface_property out_1 errorDescriptor ""
set_interface_property out_1 firstSymbolInHighOrderBits true
set_interface_property out_1 maxChannel 0
set_interface_property out_1 readyLatency 0
set_interface_property out_1 ENABLED true
set_interface_property out_1 EXPORT_OF ""
set_interface_property out_1 PORT_NAME_MAP ""
set_interface_property out_1 CMSIS_SVD_VARIABLES ""
set_interface_property out_1 SVD_ADDRESS_GROUP ""

add_interface_port out_1 out_1_ready ready Input 1
add_interface_port out_1 out_1_valid valid Output 1
add_interface_port out_1 out_1 data Output 160


# 
# connection point out_2
# 
add_interface out_2 avalon_streaming start
set_interface_property out_2 associatedClock clock_sink
set_interface_property out_2 associatedReset reset_sink
set_interface_property out_2 dataBitsPerSymbol 8
set_interface_property out_2 errorDescriptor ""
set_interface_property out_2 firstSymbolInHighOrderBits true
set_interface_property out_2 maxChannel 0
set_interface_property out_2 readyLatency 0
set_interface_property out_2 ENABLED true
set_interface_property out_2 EXPORT_OF ""
set_interface_property out_2 PORT_NAME_MAP ""
set_interface_property out_2 CMSIS_SVD_VARIABLES ""
set_interface_property out_2 SVD_ADDRESS_GROUP ""

add_interface_port out_2 out_2_ready ready Input 1
add_interface_port out_2 out_2_valid valid Output 1
add_interface_port out_2 out_2 data Output 160


# 
# connection point out_3
# 
add_interface out_3 avalon_streaming start
set_interface_property out_3 associatedClock clock_sink
set_interface_property out_3 associatedReset reset_sink
set_interface_property out_3 dataBitsPerSymbol 8
set_interface_property out_3 errorDescriptor ""
set_interface_property out_3 firstSymbolInHighOrderBits true
set_interface_property out_3 maxChannel 0
set_interface_property out_3 readyLatency 0
set_interface_property out_3 ENABLED true
set_interface_property out_3 EXPORT_OF ""
set_interface_property out_3 PORT_NAME_MAP ""
set_interface_property out_3 CMSIS_SVD_VARIABLES ""
set_interface_property out_3 SVD_ADDRESS_GROUP ""

add_interface_port out_3 out_3_ready ready Input 1
add_interface_port out_3 out_3_valid valid Output 1
add_interface_port out_3 out_3 data Output 160


# 
# connection point local_0
# 
add_interface local_0 avalon end
set_interface_property local_0 addressUnits WORDS
set_interface_property local_0 associatedClock clock_sink
set_interface_property local_0 associatedReset reset_sink
set_interface_property local_0 bitsPerSymbol 8
set_interface_property local_0 burstOnBurstBoundariesOnly false
set_interface_property local_0 burstcountUnits WORDS
set_interface_property local_0 explicitAddressSpan 0
set_interface_property local_0 holdTime 0
set_interface_property local_0 linewrapBursts false
set_interface_property local_0 maximumPendingReadTransactions 0
set_interface_property local_0 maximumPendingWriteTransactions 0
set_interface_property local_0 readLatency 0
set_interface_property local_0 readWaitTime 1
set_interface_property local_0 setupTime 0
set_interface_property local_0 timingUnits Cycles
set_interface_property local_0 writeWaitTime 0
set_interface_property local_0 ENABLED true
set_interface_property local_0 EXPORT_OF ""
set_interface_property local_0 PORT_NAME_MAP ""
set_interface_property local_0 CMSIS_SVD_VARIABLES ""
set_interface_property local_0 SVD_ADDRESS_GROUP ""

add_interface_port local_0 local_0_read read Input 1
add_interface_port local_0 local_0_write write Input 1
add_interface_port local_0 local_0_address address Input 28
add_interface_port local_0 local_0_byteenable byteenable Input 16
add_interface_port local_0 local_0_readdata readdata Output 128
add_interface_port local_0 local_0_writedata writedata Input 128
add_interface_port local_0 local_0_waitrequest waitrequest Output 1
set_interface_assignment local_0 embeddedsw.configuration.isFlash 0
set_interface_assignment local_0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment local_0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment local_0 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point local_1
# 
add_interface local_1 avalon end
set_interface_property local_1 addressUnits WORDS
set_interface_property local_1 associatedClock clock_sink
set_interface_property local_1 associatedReset reset_sink
set_interface_property local_1 bitsPerSymbol 8
set_interface_property local_1 burstOnBurstBoundariesOnly false
set_interface_property local_1 burstcountUnits WORDS
set_interface_property local_1 explicitAddressSpan 0
set_interface_property local_1 holdTime 0
set_interface_property local_1 linewrapBursts false
set_interface_property local_1 maximumPendingReadTransactions 0
set_interface_property local_1 maximumPendingWriteTransactions 0
set_interface_property local_1 readLatency 0
set_interface_property local_1 readWaitTime 1
set_interface_property local_1 setupTime 0
set_interface_property local_1 timingUnits Cycles
set_interface_property local_1 writeWaitTime 0
set_interface_property local_1 ENABLED true
set_interface_property local_1 EXPORT_OF ""
set_interface_property local_1 PORT_NAME_MAP ""
set_interface_property local_1 CMSIS_SVD_VARIABLES ""
set_interface_property local_1 SVD_ADDRESS_GROUP ""

add_interface_port local_1 local_1_read read Input 1
add_interface_port local_1 local_1_write write Input 1
add_interface_port local_1 local_1_address address Input 28
add_interface_port local_1 local_1_byteenable byteenable Input 16
add_interface_port local_1 local_1_readdata readdata Output 128
add_interface_port local_1 local_1_writedata writedata Input 128
add_interface_port local_1 local_1_waitrequest waitrequest Output 1
set_interface_assignment local_1 embeddedsw.configuration.isFlash 0
set_interface_assignment local_1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment local_1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment local_1 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point local_2
# 
add_interface local_2 avalon end
set_interface_property local_2 addressUnits WORDS
set_interface_property local_2 associatedClock clock_sink
set_interface_property local_2 associatedReset reset_sink
set_interface_property local_2 bitsPerSymbol 8
set_interface_property local_2 burstOnBurstBoundariesOnly false
set_interface_property local_2 burstcountUnits WORDS
set_interface_property local_2 explicitAddressSpan 0
set_interface_property local_2 holdTime 0
set_interface_property local_2 linewrapBursts false
set_interface_property local_2 maximumPendingReadTransactions 0
set_interface_property local_2 maximumPendingWriteTransactions 0
set_interface_property local_2 readLatency 0
set_interface_property local_2 readWaitTime 1
set_interface_property local_2 setupTime 0
set_interface_property local_2 timingUnits Cycles
set_interface_property local_2 writeWaitTime 0
set_interface_property local_2 ENABLED true
set_interface_property local_2 EXPORT_OF ""
set_interface_property local_2 PORT_NAME_MAP ""
set_interface_property local_2 CMSIS_SVD_VARIABLES ""
set_interface_property local_2 SVD_ADDRESS_GROUP ""

add_interface_port local_2 local_2_read read Input 1
add_interface_port local_2 local_2_write write Input 1
add_interface_port local_2 local_2_address address Input 28
add_interface_port local_2 local_2_byteenable byteenable Input 16
add_interface_port local_2 local_2_readdata readdata Output 128
add_interface_port local_2 local_2_writedata writedata Input 128
add_interface_port local_2 local_2_waitrequest waitrequest Output 1
set_interface_assignment local_2 embeddedsw.configuration.isFlash 0
set_interface_assignment local_2 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment local_2 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment local_2 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point local_3
# 
add_interface local_3 avalon end
set_interface_property local_3 addressUnits WORDS
set_interface_property local_3 associatedClock clock_sink
set_interface_property local_3 associatedReset reset_sink
set_interface_property local_3 bitsPerSymbol 8
set_interface_property local_3 burstOnBurstBoundariesOnly false
set_interface_property local_3 burstcountUnits WORDS
set_interface_property local_3 explicitAddressSpan 0
set_interface_property local_3 holdTime 0
set_interface_property local_3 linewrapBursts false
set_interface_property local_3 maximumPendingReadTransactions 0
set_interface_property local_3 maximumPendingWriteTransactions 0
set_interface_property local_3 readLatency 0
set_interface_property local_3 readWaitTime 1
set_interface_property local_3 setupTime 0
set_interface_property local_3 timingUnits Cycles
set_interface_property local_3 writeWaitTime 0
set_interface_property local_3 ENABLED true
set_interface_property local_3 EXPORT_OF ""
set_interface_property local_3 PORT_NAME_MAP ""
set_interface_property local_3 CMSIS_SVD_VARIABLES ""
set_interface_property local_3 SVD_ADDRESS_GROUP ""

add_interface_port local_3 local_3_read read Input 1
add_interface_port local_3 local_3_write write Input 1
add_interface_port local_3 local_3_address address Input 28
add_interface_port local_3 local_3_byteenable byteenable Input 16
add_interface_port local_3 local_3_readdata readdata Output 128
add_interface_port local_3 local_3_writedata writedata Input 128
add_interface_port local_3 local_3_waitrequest waitrequest Output 1
set_interface_assignment local_3 embeddedsw.configuration.isFlash 0
set_interface_assignment local_3 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment local_3 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment local_3 embeddedsw.configuration.isPrintableDevice 0


# 
# connection point mem_0
# 
add_interface mem_0 avalon start
set_interface_property mem_0 addressUnits SYMBOLS
set_interface_property mem_0 associatedClock clock_sink
set_interface_property mem_0 associatedReset reset_sink
set_interface_property mem_0 bitsPerSymbol 8
set_interface_property mem_0 burstOnBurstBoundariesOnly false
set_interface_property mem_0 burstcountUnits WORDS
set_interface_property mem_0 doStreamReads false
set_interface_property mem_0 doStreamWrites false
set_interface_property mem_0 holdTime 0
set_interface_property mem_0 linewrapBursts false
set_interface_property mem_0 maximumPendingReadTransactions 0
set_interface_property mem_0 maximumPendingWriteTransactions 0
set_interface_property mem_0 readLatency 0
set_interface_property mem_0 readWaitTime 1
set_interface_property mem_0 setupTime 0
set_interface_property mem_0 timingUnits Cycles
set_interface_property mem_0 writeWaitTime 0
set_interface_property mem_0 ENABLED true
set_interface_property mem_0 EXPORT_OF ""
set_interface_property mem_0 PORT_NAME_MAP ""
set_interface_property mem_0 CMSIS_SVD_VARIABLES ""
set_interface_property mem_0 SVD_ADDRESS_GROUP ""

add_interface_port mem_0 mem_0_read read Output 1
add_interface_port mem_0 mem_0_write write Output 1
add_interface_port mem_0 mem_0_address address Output 32
add_interface_port mem_0 mem_0_byteenable byteenable Output 16
add_interface_port mem_0 mem_0_readdata readdata Input 128
add_interface_port mem_0 mem_0_writedata writedata Output 128
add_interface_port mem_0 mem_0_waitrequest waitrequest Input 1


# 
# connection point mem_1
# 
add_interface mem_1 avalon start
set_interface_property mem_1 addressUnits SYMBOLS
set_interface_property mem_1 associatedClock clock_sink
set_interface_property mem_1 associatedReset reset_sink
set_interface_property mem_1 bitsPerSymbol 8
set_interface_property mem_1 burstOnBurstBoundariesOnly false
set_interface_property mem_1 burstcountUnits WORDS
set_interface_property mem_1 doStreamReads false
set_interface_property mem_1 doStreamWrites false
set_interface_property mem_1 holdTime 0
set_interface_property mem_1 linewrapBursts false
set_interface_property mem_1 maximumPendingReadTransactions 0
set_interface_property mem_1 maximumPendingWriteTransactions 0
set_interface_property mem_1 readLatency 0
set_interface_property mem_1 readWaitTime 1
set_interface_property mem_1 setupTime 0
set_interface_property mem_1 timingUnits Cycles
set_interface_property mem_1 writeWaitTime 0
set_interface_property mem_1 ENABLED true
set_interface_property mem_1 EXPORT_OF ""
set_interface_property mem_1 PORT_NAME_MAP ""
set_interface_property mem_1 CMSIS_SVD_VARIABLES ""
set_interface_property mem_1 SVD_ADDRESS_GROUP ""

add_interface_port mem_1 mem_1_read read Output 1
add_interface_port mem_1 mem_1_write write Output 1
add_interface_port mem_1 mem_1_address address Output 32
add_interface_port mem_1 mem_1_byteenable byteenable Output 16
add_interface_port mem_1 mem_1_readdata readdata Input 128
add_interface_port mem_1 mem_1_writedata writedata Output 128
add_interface_port mem_1 mem_1_waitrequest waitrequest Input 1


# 
# connection point mem_2
# 
add_interface mem_2 avalon start
set_interface_property mem_2 addressUnits SYMBOLS
set_interface_property mem_2 associatedClock clock_sink
set_interface_property mem_2 associatedReset reset_sink
set_interface_property mem_2 bitsPerSymbol 8
set_interface_property mem_2 burstOnBurstBoundariesOnly false
set_interface_property mem_2 burstcountUnits WORDS
set_interface_property mem_2 doStreamReads false
set_interface_property mem_2 doStreamWrites false
set_interface_property mem_2 holdTime 0
set_interface_property mem_2 linewrapBursts false
set_interface_property mem_2 maximumPendingReadTransactions 0
set_interface_property mem_2 maximumPendingWriteTransactions 0
set_interface_property mem_2 readLatency 0
set_interface_property mem_2 readWaitTime 1
set_interface_property mem_2 setupTime 0
set_interface_property mem_2 timingUnits Cycles
set_interface_property mem_2 writeWaitTime 0
set_interface_property mem_2 ENABLED true
set_interface_property mem_2 EXPORT_OF ""
set_interface_property mem_2 PORT_NAME_MAP ""
set_interface_property mem_2 CMSIS_SVD_VARIABLES ""
set_interface_property mem_2 SVD_ADDRESS_GROUP ""

add_interface_port mem_2 mem_2_read read Output 1
add_interface_port mem_2 mem_2_write write Output 1
add_interface_port mem_2 mem_2_address address Output 32
add_interface_port mem_2 mem_2_byteenable byteenable Output 16
add_interface_port mem_2 mem_2_readdata readdata Input 128
add_interface_port mem_2 mem_2_writedata writedata Output 128
add_interface_port mem_2 mem_2_waitrequest waitrequest Input 1


# 
# connection point mem_3
# 
add_interface mem_3 avalon start
set_interface_property mem_3 addressUnits SYMBOLS
set_interface_property mem_3 associatedClock clock_sink
set_interface_property mem_3 associatedReset reset_sink
set_interface_property mem_3 bitsPerSymbol 8
set_interface_property mem_3 burstOnBurstBoundariesOnly false
set_interface_property mem_3 burstcountUnits WORDS
set_interface_property mem_3 doStreamReads false
set_interface_property mem_3 doStreamWrites false
set_interface_property mem_3 holdTime 0
set_interface_property mem_3 linewrapBursts false
set_interface_property mem_3 maximumPendingReadTransactions 0
set_interface_property mem_3 maximumPendingWriteTransactions 0
set_interface_property mem_3 readLatency 0
set_interface_property mem_3 readWaitTime 1
set_interface_property mem_3 setupTime 0
set_interface_property mem_3 timingUnits Cycles
set_interface_property mem_3 writeWaitTime 0
set_interface_property mem_3 ENABLED true
set_interface_property mem_3 EXPORT_OF ""
set_interface_property mem_3 PORT_NAME_MAP ""
set_interface_property mem_3 CMSIS_SVD_VARIABLES ""
set_interface_property mem_3 SVD_ADDRESS_GROUP ""

add_interface_port mem_3 mem_3_read read Output 1
add_interface_port mem_3 mem_3_write write Output 1
add_interface_port mem_3 mem_3_address address Output 32
add_interface_port mem_3 mem_3_byteenable byteenable Output 16
add_interface_port mem_3 mem_3_readdata readdata Input 128
add_interface_port mem_3 mem_3_writedata writedata Output 128
add_interface_port mem_3 mem_3_waitrequest waitrequest Input 1

