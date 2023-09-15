`timescale 1ns / 10ps

module top();

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;

bit  clk;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri1 ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
tri  [NUM_I2C_BUSSES-1:0] scl;
tri  [NUM_I2C_BUSSES-1:0] sda;
bit [WB_DATA_WIDTH-1:0] read_data;

// ****************************************************************************
// Clock generator
initial begin: clk_gen
	forever begin
	#5 clk = ~clk;
	end
end: clk_gen

// ****************************************************************************
// Reset generator
initial begin: rst_gen
	#113 rst = 0;
end: rst_gen

// ****************************************************************************
// Monitor Wishbone bus and display transfers in the transcript
bit [WB_ADDR_WIDTH-1:0] addr_m;
bit [WB_DATA_WIDTH-1:0] data_m;
bit we_m;
initial begin: wb_monitoring
	#113
	forever begin
	wb_bus.master_monitor(addr_m, data_m, we_m);
	$display("address: %h, data: %h, we: %d", addr_m, data_m, we_m);
	end
end: wb_monitoring

// ****************************************************************************
// Define the flow of the simulation
initial begin: test_flow
	@(posedge clk)
	//Enabling the IICMB core
	#113 wb_bus.master_write(2'b00, 8'b11xx_xxxx);

	//1. Write byte 0x05 to the DPR. This is the ID of desired I2C bus.
	wb_bus.master_write(2'b01, 8'h05); 

	// 2. Write byte ?xxxxx110? to the CMDR. This is Set Bus command.
	wb_bus.master_write(2'b10, 8'bxxxx_x110); 

	// 3. Wait for interrupt or until DON bit of CMDR reads '1'.
	while(!irq) @(posedge clk);
  wb_bus.master_read(2'b10,read_data);
	
	// 4. Write byte "xxxxx100" to the CMDR. This is Start command.
	wb_bus.master_write(2'b10, 8'bxxxx_x100);

	// 5. Wait for interrupt or until DON bit of CMDR reads '1'.
	while(!irq) @(posedge clk);
  wb_bus.master_read(2'b10, read_data);

	// 6. Write byte 0x44 to the DPR. This is the slave address 0x22 shifted 1 bit to the left + rightmost bit = '0', which means writing.
	wb_bus.master_write(2'b01, 8'h44); 

	//7. Write byte ?xxxxx001? to the CMDR. This is Write command.
	wb_bus.master_write(2'b10, 8'bxxxx_x001);

	//8. Wait for interrupt or until DON bit of CMDR reads '1'. If instead of DON the NAK bitis '1', then slave doesn't respond.
	while(!irq) @(posedge clk);
  wb_bus.master_read(2'b10, read_data);

	//9. Write byte 0x78 to the DPR. This is the byte to be written.
	wb_bus.master_write(2'b01, 8'h78); 

	//10.Write byte ?xxxxx001? to the CMDR. This is Write command.
	wb_bus.master_write(2'b10, 8'bxxxx_x001);

	//11.Wait for interrupt or until DON bit of CMDR reads '1'.
	while(!irq) @(posedge clk);
  wb_bus.master_read(2'b10, read_data);

	//12.Write byte ?xxxxx101? to the CMDR. This is Stop command.
	wb_bus.master_write(2'b10, 8'bxxxx_x101);

	//13.Wait for interrupt or until DON bit of CMDR reads '1'.
	while(!irq) @(posedge clk);
  wb_bus.master_read(2'b10,read_data);
end

// ****************************************************************************
// Instantiate the Wishbone master Bus Functional Model
wb_if       #(
      .ADDR_WIDTH(WB_ADDR_WIDTH),
      .DATA_WIDTH(WB_DATA_WIDTH)
      )
wb_bus (
  // System sigals
  .clk_i(clk),
  .rst_i(rst),
  // Master signals
  .cyc_o(cyc),
  .stb_o(stb),
  .ack_i(ack),
  .adr_o(adr),
  .we_o(we),
  // Slave signals
  .cyc_i(),
  .stb_i(),
  .ack_o(),
  .adr_i(),
  .we_i(),
  // Shred signals
  .dat_o(dat_wr_o),
  .dat_i(dat_rd_i)
  );

// ****************************************************************************
// Instantiate the DUT - I2C Multi-Bus Controller
\work.iicmb_m_wb(str) #(.g_bus_num(NUM_I2C_BUSSES)) DUT
  (
    // ------------------------------------
    // -- Wishbone signals:
    .clk_i(clk),         // in    std_logic;                            -- Clock
    .rst_i(rst),         // in    std_logic;                            -- Synchronous reset (active high)
    // -------------
    .cyc_i(cyc),         // in    std_logic;                            -- Valid bus cycle indication
    .stb_i(stb),         // in    std_logic;                            -- Slave selection
    .ack_o(ack),         //   out std_logic;                            -- Acknowledge output
    .adr_i(adr),         // in    std_logic_vector(1 downto 0);         -- Low bits of Wishbone address
    .we_i(we),           // in    std_logic;                            -- Write enable
    .dat_i(dat_wr_o),    // in    std_logic_vector(7 downto 0);         -- Data input
    .dat_o(dat_rd_i),    //   out std_logic_vector(7 downto 0);         -- Data output
    // ------------------------------------
    // ------------------------------------
    // -- Interrupt request:
    .irq(irq),           //   out std_logic;                            -- Interrupt request
    // ------------------------------------
    // ------------------------------------
    // -- I2C interfaces:
    .scl_i(scl),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Clock inputs
    .sda_i(sda),         // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );

endmodule