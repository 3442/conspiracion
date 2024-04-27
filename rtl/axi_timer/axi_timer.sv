//axi_timer top file

module axi_timer(
  input i_clk,
  input i_rst_n,

  axi_bus.Slave axi_slave,

  output logic  o_IRQ
  );

// verilator lint_off CASEINCOMPLETE
// verilator lint_off WIDTHEXPAND
// verilator lint_off WIDTHTRUNC

enum logic [2:0] {
  CR_ADDR       = 3'd0,
  SR_ADDR       = 3'd1,
  PERIOD_ADDR   = 3'd2,
  COUNTER_ADDR  = 3'd3,
  IRQ_CNT_ADDR  = 3'd4
} address_map;

/*Register map for axi_timer */
//CR register
logic         enable;
//SR register
logic         irq;
//PERIOD register
logic [31:0]  period;
//COUNTER register
logic [31:0]  counter;
//IRQ_CNT register
logic [31:0]  irq_cnt;

/* Native interface for access to register */
logic         addr_valid;
logic         addr;
logic         addr_ready;
logic         addr_write;

logic         write_valid;
logic [31:0]  wdata;
logic         write_ready;

logic         read_valid;
logic [31:0]  rdata;
logic         read_ready;

/* Address section */
assign  addr_valid        = axi_slave.AVALID;
assign  addr_write        = axi_slave.AWRITE;
assign  axi_slave.AREADY  = addr_ready;

always_ff @ (posedge i_clk, negedge i_rst_n)
  if(!i_rst_n)
    addr_ready  <=  1'b0;
  else if(addr_valid & addr_write)
    addr_ready  <=  1'b1;
  else
    addr_ready  <=  1'b0;

always_ff @ (posedge i_clk, negedge i_rst_n)
  if(!i_rst_n)
    addr  <=  'h0;
  else if(addr_ready & addr_write)
    addr  <=  axi_slave.ADDR;

/*Write section */
assign  write_valid       = axi_slave.WVALID;
assign  axi_slave.WREADY  = write_ready;
assign  wdata             = axi_slave.WDATA;

always_ff @ (posedge i_clk, negedge i_rst_n)
  if(!i_rst_n)
    write_ready <=  1'b0;
  else if(write_valid)
    write_ready <=  1'b1;
  else
    write_ready <=  1'b0;

/* registers write logic */
always_ff @ (posedge i_clk, negedge i_rst_n)
  if(!i_rst_n) begin
    enable  <=  1'b0;
    period  <=  32'd0;
    irq_cnt <=  32'd0;
  end
  else if(write_valid) begin
    case(addr)
      CR_ADDR:      enable  <=  wdata[0];
      PERIOD_ADDR:  counter <=  wdata;
      IRQ_CNT_ADDR: irq_cnt <=  wdata;
    endcase
  end

/*Read section */
assign axi_slave.RVALID = read_valid;
assign read_ready = axi_slave.RREADY;
assign axi_slave.RDATA = rdata;

always_ff @ (posedge i_clk, negedge i_rst_n)
  if(!i_rst_n) begin
    rdata       <=  32'd0;
    read_valid  <=  1'b0;
  end
  else if(read_ready) begin
    read_valid  <=  1'b1;
    case(addr)
      CR_ADDR:      rdata <=  {31'd0, enable};
      SR_ADDR:      rdata <=  {31'd0, irq};
      PERIOD_ADDR:  rdata <=  period;
      COUNTER_ADDR: rdata <=  counter;
      IRQ_CNT_ADDR: rdata <=  irq_cnt;
    endcase
  end
  else begin
    read_valid  <=  1'b0;
    rdata       <=  32'd0;
  end




endmodule //axi_timer
