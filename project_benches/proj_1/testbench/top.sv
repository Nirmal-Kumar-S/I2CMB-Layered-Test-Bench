`timescale 1ns / 10ps
`include "../../../verification_ip/interface_packages/i2c_pkg/src/i2c_if.sv"

module top();

import ncsu_pkg::*;
import i2c_pkg::*;
import wb_pkg::*;

parameter int WB_ADDR_WIDTH = 2;
parameter int WB_DATA_WIDTH = 8;
parameter int NUM_I2C_BUSSES = 1;
parameter int I2C_ADDR_WIDTH = 8;
parameter int I2C_DATA_WIDTH = 8;

bit  clk = 1'b0;
bit  rst = 1'b1;
wire cyc;
wire stb;
wire we;
tri ack;
wire [WB_ADDR_WIDTH-1:0] adr;
wire [WB_DATA_WIDTH-1:0] dat_wr_o;
wire [WB_DATA_WIDTH-1:0] dat_rd_i;
wire irq;
triand  [NUM_I2C_BUSSES-1:0] scl;
triand  [NUM_I2C_BUSSES-1:0] sda;

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
	//$display("address: %h, data: %h, we: %d", addr_m, data_m, we_m);
	end
end: wb_monitoring

// ****************************************************************************
// Task to write the value into the slave
byte DON_CMDR;
task write_data_seq (input int n, input int value);
	int i;
	
	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1
	
	wb_bus.master_write(2'b01, 8'h01);	//3.1
	
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h02);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	for(i = 0; i < n; i++) begin
		wb_bus.master_write(2'b01, value);	//3.9

		wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.10

		while(!irq) @(posedge clk); //3.11

		wb_bus.master_read(2'b10, DON_CMDR);

	end
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);
endtask

// ****************************************************************************
// Task to read the value from the slave
task read_data_seq(input int n);
	bit [7:0] data_read;

	wb_bus.master_write(2'b00, 8'b11xx_xxxx);	//1

	wb_bus.master_write(2'b01, 8'h01);	//3.1
	
	wb_bus.master_write(2'b10, 8'bxxxx_x110);	//3.2

	while(!irq) @(posedge clk); //3.3
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b10, 8'bxxxx_x100);	//3.4

	while(!irq) @(posedge clk);	//3.5
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_write(2'b01, 8'h03);	//3.6 slave address

	wb_bus.master_write(2'b10, 8'bxxxx_x001);	//3.7

	while(!irq) @(posedge clk);	//3.8
	wb_bus.master_read(2'b10, DON_CMDR);

	repeat(n - 1) begin
		wb_bus.master_write(2'b10, 8'bxxxx_x010);	//3.10 read with ack

		while(!irq) @(posedge clk); //3.11
		wb_bus.master_read(2'b10, DON_CMDR);

		wb_bus.master_read(2'b01, data_read);
	end
	wb_bus.master_write(2'b10, 8'bxxxx_x011);	//3.10 read with not-ack

	while(!irq) @(posedge clk); //3.11
	wb_bus.master_read(2'b10, DON_CMDR);

	wb_bus.master_read(2'b01, data_read);
	
	wb_bus.master_write(2'b10, 8'bxxxx_x101);	//3.12

	while(!irq) @(posedge clk);	//3.13
	wb_bus.master_read(2'b10, DON_CMDR);
endtask

// ****************************************************************************
// Provide read data values
int checkpoint;
initial begin: loop
	i2c_op_t operation;
	bit [I2C_DATA_WIDTH-1:0] WRITE_DATA[];
	bit [I2C_DATA_WIDTH-1:0] READ_DATA[];
	static int  i = 0;
	static int j = 0;
	READ_DATA = new[1];
	#113
	forever	begin
	i2c_bus.wait_for_i2c_transfer(operation, WRITE_DATA);
	if(operation == READ)	begin
		if(checkpoint == 1) begin
			READ_DATA[0] = 100 + i;
			i2c_bus.provide_read_data(READ_DATA);
			i++;
			end
		else begin
			READ_DATA[0] = 63 - j;
			i2c_bus.provide_read_data(READ_DATA);
			j++;
			end
		end
	end
end: loop

// ****************************************************************************
// Verification
initial begin: testbench
	static int value = 0;
	#113
	$display("\nTask1 : Master writing incrementing values from 0 to 31 and sending to slave.");
	$display("-----------------------------------------------------------------------------\n");
	repeat(32) begin
	write_data_seq(1, value);
	value++;
	end

	checkpoint = 1;
	
	$display("\nTask 2:    Master reading incrementing values from 100 to 131 from the slave.");
	$display("-----------------------------------------------------------------------------\n");
	repeat(32) begin
	read_data_seq(1);
	end
	
	value = 64;
	checkpoint = 0;
	
	$display("\nTask 3 : Alternate reads/writes happening. Writes happening from 64 to 127(incrementing) and reads from 63 to 0(decrementing)");
	$display("-----------------------------------------------------------------------------------------------------------------------------\n");
	repeat(64) begin
	write_data_seq(1, value);
	read_data_seq(1);
	value++;
	end
end: testbench

// ****************************************************************************
// Monitor I2C bus and display transfers in the transcript
initial begin:monitor_i2c_bus
	bit [I2C_ADDR_WIDTH -1 : 0] monitor_addr;
	i2c_op_t monitor_op;
	bit [I2C_DATA_WIDTH-1:0] monitor_data[];
	forever begin

	i2c_bus.monitor(monitor_addr, monitor_op, monitor_data);
	if(monitor_op == WRITE)
		$display("Address: %d, Operation: WRITE, Data: %p", monitor_addr, monitor_data);
	else
		$display("Address: %d, Operation: READ, Data: %p", monitor_addr, monitor_data);

	//$display("========== STOP ===========");
	end
end: monitor_i2c_bus

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
// Instantiate the I2C
	i2c_if       #(.I2C_ADDR_WIDTH(I2C_ADDR_WIDTH), .I2C_DATA_WIDTH(I2C_DATA_WIDTH))
	i2c_bus (.SCL(scl), .SDA_O(sda));

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
    .sda_i(sda),        // in    std_logic_vector(0 to g_bus_num - 1); -- I2C Data inputs
    .scl_o(scl),         //   out std_logic_vector(0 to g_bus_num - 1); -- I2C Clock outputs
    .sda_o(sda)          //   out std_logic_vector(0 to g_bus_num - 1)  -- I2C Data outputs
    // ------------------------------------
  );
endmodule