`include "../../ncsu_pkg/ncsu_pkg.sv"

package i2c_pkg;

	import ncsu_pkg::*;
	
	`include "../../ncsu_pkg/ncsu_macros.svh"
    typedef enum bit {WRITE = 1'b0, READ = 1'b1} i2c_op_t;
	`include "src/i2c_configuration.svh"
	`include "src/i2c_transaction.svh"
	`include "src/i2c_driver.svh"
	`include "src/i2c_monitor.svh"
	`include "src/i2c_agent.svh"

endpackage
