# TCL File Generated by Component Editor 20.1
# Mon Nov 20 21:56:17 GMT 2023
# DO NOT MODIFY


# 
# gfx "3D graphics accelerator" v1.0
#  2023.11.20.21:56:17
# 
# 

# 
# request TCL package from ACDS 16.1
# 
package require -exact qsys 16.1


# 
# module gfx
# 
set_module_property DESCRIPTION ""
set_module_property NAME gfx
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "3D graphics accelerator"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false


# 
# file sets
# 
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL gfx
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file gfx.sv SYSTEM_VERILOG PATH rtl/gfx/gfx.sv TOP_LEVEL_FILE
add_fileset_file gfx_fp_add.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fp_add.sv
add_fileset_file gfx_fp_inv.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fp_inv.sv
add_fileset_file gfx_fp_mul.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fp_mul.sv
add_fileset_file gfx_fixed_div.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fixed_div.sv
add_fileset_file gfx_fixed_fma.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fixed_fma.sv
add_fileset_file gfx_fixed_fma_dot.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fixed_fma_dot.sv
add_fileset_file gfx_cmd.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_cmd.sv
add_fileset_file gfx_defs.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_defs.sv
add_fileset_file gfx_fold.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fold.sv
add_fileset_file gfx_mat_mat.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_mat_mat.sv
add_fileset_file gfx_mat_vec.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_mat_vec.sv
add_fileset_file gfx_flush_flow.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_flush_flow.sv
add_fileset_file gfx_pipeline_flow.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_pipeline_flow.sv
add_fileset_file gfx_fold_flow.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fold_flow.sv
add_fileset_file gfx_skid_flow.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_skid_flow.sv
add_fileset_file gfx_skid_buf.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_skid_buf.sv
add_fileset_file gfx_pipes.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_pipes.sv
add_fileset_file gfx_dot.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_dot.sv
add_fileset_file gfx_transpose.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_transpose.sv
add_fileset_file gfx_scanout.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_scanout.sv
add_fileset_file gfx_scanout_dac.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_scanout_dac.sv
add_fileset_file gfx_masks.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_masks.sv
add_fileset_file gfx_mask_sram.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_mask_sram.sv
add_fileset_file gfx_setup.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_setup.sv
add_fileset_file gfx_setup_edge.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_setup_edge.sv
add_fileset_file gfx_setup_bounds.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_setup_bounds.sv
add_fileset_file gfx_setup_offsets.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_setup_offsets.sv
add_fileset_file gfx_raster.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_raster.sv
add_fileset_file gfx_raster_fine.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_raster_fine.sv
add_fileset_file gfx_raster_coarse.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_raster_coarse.sv
add_fileset_file gfx_clear.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_clear.sv
add_fileset_file gfx_lerp.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_lerp.sv
add_fileset_file gfx_funnel.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_funnel.sv
add_fileset_file gfx_frag.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_frag.sv
add_fileset_file gfx_frag_addr.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_frag_addr.sv
add_fileset_file gfx_frag_bary.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_frag_bary.sv
add_fileset_file gfx_frag_shade.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_frag_shade.sv
add_fileset_file gfx_rop.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_rop.sv
add_fileset_file gfx_fifo.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fifo.sv
add_fileset_file gfx_fifo_overflow.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_fifo_overflow.sv
add_fileset_file gfx_mem.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_mem.sv
add_fileset_file gfx_sp.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_sp.sv
add_fileset_file gfx_sp_batch.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_sp_batch.sv
add_fileset_file gfx_sp_fetch.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_sp_fetch.sv
add_fileset_file gfx_sp_widener.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_sp_widener.sv
add_fileset_file gfx_shuffle.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_shuffle.sv
add_fileset_file gfx_swizzle.sv SYSTEM_VERILOG PATH rtl/gfx/gfx_swizzle.sv


# 
# parameters
# 


# 
# display items
# 


# 
# connection point clock
# 
add_interface clock clock end
set_interface_property clock clockRate 0
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""

add_interface_port clock clk clk Input 1


# 
# connection point cmd
# 
add_interface cmd avalon end
set_interface_property cmd addressUnits WORDS
set_interface_property cmd associatedClock clock
set_interface_property cmd associatedReset reset_sink
set_interface_property cmd bitsPerSymbol 8
set_interface_property cmd burstOnBurstBoundariesOnly false
set_interface_property cmd burstcountUnits WORDS
set_interface_property cmd explicitAddressSpan 0
set_interface_property cmd holdTime 0
set_interface_property cmd linewrapBursts false
set_interface_property cmd maximumPendingReadTransactions 0
set_interface_property cmd maximumPendingWriteTransactions 0
set_interface_property cmd readLatency 0
set_interface_property cmd readWaitTime 1
set_interface_property cmd setupTime 0
set_interface_property cmd timingUnits Cycles
set_interface_property cmd writeWaitTime 0
set_interface_property cmd ENABLED true
set_interface_property cmd EXPORT_OF ""
set_interface_property cmd PORT_NAME_MAP ""
set_interface_property cmd CMSIS_SVD_VARIABLES ""
set_interface_property cmd SVD_ADDRESS_GROUP ""

add_interface_port cmd cmd_address address Input 6
add_interface_port cmd cmd_read read Input 1
add_interface_port cmd cmd_write write Input 1
add_interface_port cmd cmd_writedata writedata Input 32
add_interface_port cmd cmd_readdata readdata Output 32
set_interface_assignment cmd embeddedsw.configuration.isFlash 0
set_interface_assignment cmd embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment cmd embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment cmd embeddedsw.configuration.isPrintableDevice 0


# 
# connection point reset_sink
# 
add_interface reset_sink reset end
set_interface_property reset_sink associatedClock clock
set_interface_property reset_sink synchronousEdges DEASSERT
set_interface_property reset_sink ENABLED true
set_interface_property reset_sink EXPORT_OF ""
set_interface_property reset_sink PORT_NAME_MAP ""
set_interface_property reset_sink CMSIS_SVD_VARIABLES ""
set_interface_property reset_sink SVD_ADDRESS_GROUP ""

add_interface_port reset_sink rst_n reset_n Input 1


# 
# connection point mem
# 
add_interface mem avalon start
set_interface_property mem addressUnits SYMBOLS
set_interface_property mem associatedClock clock
set_interface_property mem associatedReset reset_sink
set_interface_property mem bitsPerSymbol 8
set_interface_property mem burstOnBurstBoundariesOnly false
set_interface_property mem burstcountUnits WORDS
set_interface_property mem doStreamReads false
set_interface_property mem doStreamWrites false
set_interface_property mem holdTime 0
set_interface_property mem linewrapBursts false
set_interface_property mem maximumPendingReadTransactions 0
set_interface_property mem maximumPendingWriteTransactions 0
set_interface_property mem readLatency 0
set_interface_property mem readWaitTime 1
set_interface_property mem setupTime 0
set_interface_property mem timingUnits Cycles
set_interface_property mem writeWaitTime 0
set_interface_property mem ENABLED true
set_interface_property mem EXPORT_OF ""
set_interface_property mem PORT_NAME_MAP ""
set_interface_property mem CMSIS_SVD_VARIABLES ""
set_interface_property mem SVD_ADDRESS_GROUP ""

add_interface_port mem mem_address address Output 26
add_interface_port mem mem_read read Output 1
add_interface_port mem mem_write write Output 1
add_interface_port mem mem_readdatavalid readdatavalid Input 1
add_interface_port mem mem_readdata readdata Input 16
add_interface_port mem mem_writedata writedata Output 16
add_interface_port mem mem_waitrequest waitrequest Input 1


# 
# connection point scan
# 
add_interface scan avalon_streaming start
set_interface_property scan associatedClock clock
set_interface_property scan associatedReset reset_sink
set_interface_property scan dataBitsPerSymbol 10
set_interface_property scan errorDescriptor ""
set_interface_property scan firstSymbolInHighOrderBits true
set_interface_property scan maxChannel 0
set_interface_property scan readyLatency 0
set_interface_property scan ENABLED true
set_interface_property scan EXPORT_OF ""
set_interface_property scan PORT_NAME_MAP ""
set_interface_property scan CMSIS_SVD_VARIABLES ""
set_interface_property scan SVD_ADDRESS_GROUP ""

add_interface_port scan scan_data data Output 30
add_interface_port scan scan_endofpacket endofpacket Output 1
add_interface_port scan scan_ready ready Input 1
add_interface_port scan scan_startofpacket startofpacket Output 1
add_interface_port scan scan_valid valid Output 1


# 
# connection point host
# 
add_interface host avalon end
set_interface_property host addressUnits WORDS
set_interface_property host associatedClock clock
set_interface_property host associatedReset reset_sink
set_interface_property host bitsPerSymbol 8
set_interface_property host burstOnBurstBoundariesOnly false
set_interface_property host burstcountUnits WORDS
set_interface_property host explicitAddressSpan 0
set_interface_property host holdTime 0
set_interface_property host linewrapBursts false
set_interface_property host maximumPendingReadTransactions 13
set_interface_property host maximumPendingWriteTransactions 0
set_interface_property host readLatency 0
set_interface_property host readWaitTime 1
set_interface_property host setupTime 0
set_interface_property host timingUnits Cycles
set_interface_property host writeWaitTime 0
set_interface_property host ENABLED true
set_interface_property host EXPORT_OF ""
set_interface_property host PORT_NAME_MAP ""
set_interface_property host CMSIS_SVD_VARIABLES ""
set_interface_property host SVD_ADDRESS_GROUP ""

add_interface_port host host_address address Input 25
add_interface_port host host_read read Input 1
add_interface_port host host_write write Input 1
add_interface_port host host_readdata readdata Output 16
add_interface_port host host_writedata writedata Input 16
add_interface_port host host_readdatavalid readdatavalid Output 1
add_interface_port host host_waitrequest waitrequest Output 1
set_interface_assignment host embeddedsw.configuration.isFlash 0
set_interface_assignment host embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment host embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment host embeddedsw.configuration.isPrintableDevice 0

