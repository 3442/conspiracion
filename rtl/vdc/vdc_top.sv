module vdc_top
import vdc_pkg::*, vdc_if_pkg::*;
(
	input  logic      clk,
	                  rst_n,

	       if_axil.s  host,

	       if_axib.m  stream,

	       vdc_dac.tx dac
);

	axi4lite_intf #(.ADDR_WIDTH(VDC_IF_MIN_ADDR_WIDTH)) regblock();
	vdc_if__in_t if_in;
	vdc_if__out_t if_out;

	logic csr_back_push, csr_dac_enable, csr_dac_on, csr_double_buff,
	      csr_back_set, csr_front_set, frame_done, frame_start;

	ptr csr_back, csr_back_next, csr_front, csr_front_next, csr_retired, front_base;
	geom_dim csr_lines, csr_line_len, csr_stride, lines, line_len, stride;

	assign csr_dac_enable = if_out.CTRL.DACEN.value;
	assign csr_double_buff = if_out.CTRL.DOUBLEBUFF.value;
	assign if_in.CTRL.DACON.next = csr_dac_on;

	assign csr_lines = if_out.GEOMETRY.LINES.value;
	assign csr_line_len = if_out.GEOMETRY.LENGTH.value;

	assign csr_stride = if_out.STREAM.HSTRIDE.value;

	assign csr_front = if_out.FRONT.ADDR.value;
	assign if_in.FRONT.ADDR.we = csr_front_set;
	assign if_in.FRONT.ADDR.next = csr_front_next;

	assign csr_back = if_out.BACK.ADDR.value;
	assign csr_back_push = if_out.BACK.ADDR.swmod;
	assign if_in.BACK.ADDR.we = csr_back_set;
	assign if_in.BACK.ADDR.next = csr_back_next;

	assign if_in.RETIRE.ADDR.next = csr_retired;

	vdc_if regif
	(
		.clk,
		.arst_n(rst_n),
		.s_axil(regblock.slave),
		.hwif_in(if_in),
		.hwif_out(if_out)
	);

	if_axil2regblock axil2regblock
	(
		.axis(host),
		.axim(regblock.master)
	);

	vdc_io io
	(
		.clk,
		.rst_n,
		.dac,
		.lines,
		.stream,
		.stride,
		.line_len,
		.frame_done,
		.front_base,
		.frame_start
	);

	vdc_sync sync
	(
		.clk,
		.rst_n,

		.csr_back,
		.csr_front,
		.csr_lines,
		.csr_dac_on,
		.csr_stride,
		.csr_retired,
		.csr_back_set,
		.csr_line_len,
		.csr_back_next,
		.csr_back_push,
		.csr_front_set,
		.csr_dac_enable,
		.csr_front_next,
		.csr_double_buff,

		.lines,
		.stride,
		.line_len,
		.frame_done,
		.front_base,
		.frame_start
	);

endmodule
