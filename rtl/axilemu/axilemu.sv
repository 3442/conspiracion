module axilemu
import axilemu_if_pkg::*;
(
	input  logic     clk,
	                 rst_n,

	       if_axil.s agent,
	                 driver,

	output logic     irq
);

	axi4lite_intf #(.ADDR_WIDTH(AXILEMU_IF_MIN_ADDR_WIDTH)) regblock();

	axilemu_if__in_t if_in;
	axilemu_if__out_t if_out;

	assign agent.rdata = if_out.R.DATA.value;
	assign agent.bvalid = if_out.B.VALID.value;

	assign if_in.CTRL.BDONE.hwset = agent.bvalid & agent.bready;
	assign if_in.CTRL.RDONE.hwset = agent.rvalid & agent.rready;
	assign if_in.CTRL.WVALID.next = agent.wvalid;
	assign if_in.CTRL.ARVALID.next = agent.arvalid;
	assign if_in.CTRL.AWVALID.next = agent.awvalid;

	assign if_in.AR.ADDR.next = agent.araddr[31:2];
	assign if_in.AR.VALID.hwset = agent.arvalid & ~agent.arready & ~if_out.AR.VALID.value;

	assign if_in.AW.ADDR.next = agent.awaddr[31:2];
	assign if_in.AW.VALID.hwset = agent.awvalid & ~agent.awready & ~if_out.AW.VALID.value;

	assign if_in.W.DATA.next = agent.wdata;

	assign if_in.B.VALID.hwclr = agent.bvalid & agent.bready;

	if_axil2regblock axil2regblock
	(
		.axis(driver),
		.axim(regblock.master)
	);

	axilemu_if regif
	(
		.clk,
		.arst_n(rst_n),
		.s_axil(regblock.slave),
		.hwif_in(if_in),
		.hwif_out(if_out)
	);

	always_ff @(posedge clk or negedge rst_n)
		if (~rst_n) begin
			irq <= 0;

			agent.rvalid <= 0;
			agent.wready <= 0;
			agent.arready <= 0;
			agent.awready <= 0;
		end else begin
			irq <= (if_out.CTRL.ARINT.value & agent.arvalid)
			     | (if_out.CTRL.AWINT.value & agent.awvalid);

			agent.rvalid <= if_out.R.DATA.swmod | (agent.rvalid & ~agent.rready);
			agent.wready <= agent.wvalid & if_out.W.DATA.swacc;
			agent.arready <= agent.arvalid & if_out.AR.VALID.swmod;
			agent.awready <= agent.awvalid & if_out.AW.VALID.swmod;
		end

endmodule
