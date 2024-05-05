module gfx_axil2regblock
(
	gfx_axil.s           axis,
	axi4lite_intf.master axim
);

	assign axis.rdata = axim.RDATA;
	assign axis.rvalid = axim.RVALID;
	assign axis.bvalid = axim.BVALID;
	assign axis.wready = axim.WREADY;
	assign axis.arready = axim.ARREADY;
	assign axis.awready = axim.AWREADY;

    assign axim.AWVALID = axis.awvalid;
    assign axim.AWADDR = axis.awaddr[$bits(axim.AWADDR) - 1:0];
    assign axim.AWPROT = '0;

    assign axim.WVALID = axis.wvalid;
    assign axim.WDATA = axis.wdata;
    assign axim.WSTRB = '1;

    assign axim.BREADY = axis.bready;

    assign axim.ARVALID = axis.arvalid;
    assign axim.ARADDR = axis.araddr[$bits(axim.ARADDR) - 1:0];
    assign axim.ARPROT = '0;

    assign axim.RREADY = axis.rready;

endmodule
