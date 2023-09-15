interface i2c_if #(int I2C_DATA_WIDTH = 8, int I2C_ADDR_WIDTH = 8)(input tri SCL, inout tri SDA_O);
	
	import i2c_pkg::*;
	
	bit sda = 1'b1;
	bit [I2C_ADDR_WIDTH-1:0] slave_address = 8'h22;
	int start_flag = 0;
	int reset_flag = 0;
	int data_i= 0;
	int monitor_start_flag = 0; 
	int monitor_reset_flag =0;
	int monitor_data_i= 0;
	int index = 0;
	bit [I2C_DATA_WIDTH-1:0] monitor_data;
	
	assign SDA_O = sda ? 'bz : 'b0;

	//The wait_for_i2c_transfer task is called in order to wait for an i2c transfer to be initiated by the DUT.
	//The task will block until the transfer has been initiated and the initial part of the transfer has been captured.
	//The task returns the information received in the first part of the transfer.
	task wait_for_i2c_transfer(output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] write_data[]);
	
		int i;
		bit [I2C_DATA_WIDTH-1:0] i2c_addr; 
		bit [I2C_DATA_WIDTH-1:0] i2c_data;

		if (!reset_flag)
		begin
			do
			@(negedge SDA_O);
			while(!SCL);	
		end
		reset_flag = 0;

		//START Detected		
		start_flag = 1;	

		//Transfer the device address bits one by one from the SDA_O line
		@(posedge SCL)
			i2c_addr[6] = SDA_O;
		@(posedge SCL)
			i2c_addr[5] = SDA_O;
		@(posedge SCL)
			i2c_addr[4] = SDA_O;
		@(posedge SCL)
			i2c_addr[3] = SDA_O;
		@(posedge SCL)
			i2c_addr[2] = SDA_O;
		@(posedge SCL)
			i2c_addr[1] = SDA_O;
		@(posedge SCL)
			i2c_addr[0] = SDA_O;
		@(posedge SCL);

		//Check for the slave address to be equal to the address recieved on the SDA_O line
		if(slave_address == i2c_addr)
		@(negedge SCL)
		begin
			sda =0;                            // pull the Sda line low if the address is right - ACK
			if(!SDA_O)						   // check for the last bit in the address and set the operation type on that basis
			begin
				op = WRITE;
			end                                 
			else if(SDA_O)
			begin
				op = READ;
			end
		end 
		
		if(start_flag == 1 && op == WRITE)
		begin			
			i = 0;
			forever
			begin
				@(negedge SCL);
				sda = 1;						// release the SDA line to 1 again

				@(posedge SCL);
				@(SDA_O or negedge SCL);
				if (!SCL)						// Data transfer only possible if SCL is kept low
				begin
					//Transfer the 8 data bits from the SDA_O line to the local data array
					i2c_data [7] = SDA_O;
					@ (posedge SCL);
					i2c_data [6] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [5] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [4] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [3] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [2] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [1] = SDA_O;
					
					@ (posedge SCL);
					i2c_data [0] = SDA_O;	
				
					data_i++;
					write_data = new[data_i](write_data); 		//Copy the data addresses into a new data array in case of bursts of addresses
					write_data[i] = i2c_data;					// Transfer the address from local array to the argument
					i++;

					@(negedge SCL);
					sda = 0;
					i2c_data = 0;
                    @(posedge SCL);
				end
				else if(!SDA_O) 
				begin
					reset_flag = 1;    // Repeated Start detected , set restart flag as 1 and start_flag as 0 so as to re - enter into start 
					start_flag = 0;
					break; 
				end 
				else if(SDA_O) 
				begin	
					break;              // If SDA_0 goes from low to high then Stop Detected 
				end
			end
		end
	endtask
	
	//If the transfer is a read operation, the responder needs to provide data to the DUT at the end of the transfer.
	//The provide_read_data task provides read data to complete a read operation.	
	task provide_read_data(input bit [I2C_DATA_WIDTH-1:0] read_data[]);

		int i,length;
		i=0; 
		length = read_data.size();
		@(posedge SCL);
		if (SDA_O)
		begin
			//wait for restart or stop
		end
		else if (!SDA_O)
		begin
			forever
			begin 
				//READ the contents of an argument array onto the sda line bit by bit
				@(negedge SCL);			
				sda = read_data[i][7];				
				@(negedge SCL);
				sda = read_data[i][6];
				@(negedge SCL);
				sda = read_data[i][5];
				@(negedge SCL);
				sda = read_data[i][4];
				@(negedge SCL);
				sda = read_data[i][3];
				@(negedge SCL);
				sda = read_data[i][2];
				@(negedge SCL);
				sda = read_data[i][1];
				@(negedge SCL);
				sda = read_data[i][0];
				
				i++;
				@(negedge SCL);
				
				if(i < length)
				begin 
					sda = 0;                      // pull the sda line low - ACK until the total capacity of reading data has been fulfilled
				end
				else if (i == length )
				begin
					sda = 1; 					 // Keep the Sda line high for NACK to indicate this amount of data can only be read
				end 

				@(posedge SCL);

				if(SDA_O)  
				@(posedge SCL)
				begin
					//wait for restart or stop
					reset_flag = 1;	//If SDA_0 goes from low to high then Stop Detected, Set Restart flag as 1 
					break;
				end
			end
		end
	endtask
	
	//The monitor task observes the full transfer and returns observed information from the transfer
	task monitor(output bit [I2C_ADDR_WIDTH-1:0] addr, output i2c_op_t op, output bit [I2C_DATA_WIDTH-1:0] data[]);
		
		int i,j;
		data.delete();                              // delete the any previous data 
				
		if (!monitor_reset_flag)
		begin
			do
			@(negedge SDA_O);
			while(!SCL);	
		end
		monitor_reset_flag = 0;

		//START detected in monitor_task
		if(monitor_start_flag == 0)
		begin
			//Transfer the device address bits one by one from the SDA_O line
			@(posedge SCL)
			addr[6] = SDA_O;
			@(posedge SCL)
			addr[5] = SDA_O;
			@(posedge SCL)
			addr[4] = SDA_O;
			@(posedge SCL)
			addr[3] = SDA_O;
			@(posedge SCL)
			addr[2] = SDA_O;
			@(posedge SCL)
			addr[1] = SDA_O;
			@(posedge SCL)
			addr[0] = SDA_O;
			@(posedge SCL);

			monitor_start_flag = 1;

			//Check for the set slave address to be equal to the address recieved on the SDA_O line
			if(slave_address == addr)
			@(negedge SCL)
			begin
				if(!SDA_O)
				begin
					op = WRITE;
				end 						//check for the last bit in the address and set the operation type on that basis
				else if(SDA_O)
				begin
					op = READ;
				end
			end 
			 @(posedge SCL);
		end

		if(monitor_start_flag == 1)			
		begin 
			forever 
			begin
				@(negedge SCL);
				@(posedge SCL);
				monitor_data_i++;
				@(SDA_O or negedge SCL);
				if(!SCL)                       // Data transfer only possible if SCL is kept low
				begin
					// Transfer the 8 data bits from the SDA_O line to the local data array
					monitor_data[7] = SDA_O;
					@(posedge SCL)
					monitor_data[6] = SDA_O;
					@(posedge SCL)
					monitor_data[5] = SDA_O;
					@(posedge SCL)
					monitor_data[4] = SDA_O;
					@(posedge SCL)
					monitor_data[3] = SDA_O;
					@(posedge SCL)
					monitor_data[2] = SDA_O;
					@(posedge SCL)
					monitor_data[1] = SDA_O;
					@(posedge SCL)
					monitor_data[0] = SDA_O;

					data = new[monitor_data_i](data);  // Copy the data addresses into a new data array in case of bursts of addresses

					data [index] = monitor_data;     // Transfer the address from local array to the argument
					index++;

					@(negedge SCL);
					@ (posedge SCL);
					if(SDA_O)  
					@(posedge SCL)
					begin	
						monitor_start_flag = 0;
						monitor_reset_flag = 1;
						monitor_data_i = 0;
						index = 0;
						break;
					end
				end
				else if (SDA_O)								// Stop Condition 
				begin
					monitor_start_flag = 0;
					monitor_data_i = 0;
					index = 0;
					break;
				end
				else if  (!SDA_O)                          // Start Detection / Restart
				begin
					monitor_start_flag = 0;
					monitor_reset_flag = 1;
					monitor_data_i = 0;
					index = 0;
					break;
				end
			end
		end
	endtask
//***********************************************************************************************//	
endinterface
