//AXI interface bus
interface axi_bus #(
  parameter int unsigned  AXI_ADDR_WIDTH  = 32,
  parameter int unsigned  AXI_DATA_WIDTH  = 32
  );

  logic [AXI_ADDR_WIDTH-1:0] ADDR;
  logic                      AVALID;
  logic                      AREADY;
  logic                      AWRITE;
  logic                      WVALID;
  logic                      WREADY;
  logic [AXI_DATA_WIDTH-1:0] WDATA;
  logic                      RVALID;
  logic                      RREADY;
  logic [AXI_DATA_WIDTH-1:0] RDATA;

  modport Master(
    input   AREADY, WREADY, RVALID, RDATA,
    output  ADDR, AVALID, AWRITE, WVALID, WDATA, RREADY
  );

  modport Slave(
    input   ADDR, AVALID, AWRITE, WVALID, WDATA, RREADY,
    output  AREADY, WREADY, RVALID, RDATA
  );

endinterface
