class i2cmb_predictor extends ncsu_component#(.T(wb_transaction));

  	ncsu_component #(i2c_transaction) scoreboard; //handle of scoreboard parameterized with WB transaction class
    i2cmb_env_configuration configuration;  //handle of env config
    i2c_transaction trans_i2c;  //handle of I2C transaction
    i2c_transaction transport_trans_i2c;  

    //some flags to keep track of detection of certain conditions
    bit bus_flag=0;
    bit slave_address_flag=0;
    bit start_flag=0;  
    bit first_start_flag =0; 
    bit repeated_start_flag=0; 
    bit stop_flag=0;

    //calling new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        trans_i2c = new("name");
    endfunction

    //user defined function to set the configuration
    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    //user defined function to set scoreboard
    virtual function void set_scoreboard(ncsu_component#(i2c_transaction) scoreboard);
        this.scoreboard = scoreboard;
    endfunction

    //actual functioanlity of predictor in this function
    virtual function void nb_put(T trans);
    	//I2C bus ID detect
    	if(trans.wb_data==8'b110 && trans.wb_addr == 2'b10)   
        begin 
            bus_flag = 1;
        end
    	//start detection - first or repeated?
        if(trans.wb_data==8'b100 && trans.wb_addr == 2'b10) 
        begin 
            stop_flag = 0;
            slave_address_flag = 0;
            if(first_start_flag==0)              // Firts Start Detected
            begin
                start_flag = 1;
            end
            else if(first_start_flag==1)         // Repeated Start Detected
            begin
                repeated_start_flag = 1;
            end
        end

        if(trans.wb_addr == 2'b10 && trans.wb_data==8'b101)   //Reset Bus - STOP
    	begin 
			//reset introduced - Reset start, first_start and repeated_start flags and set bus to 0
			stop_flag = 1;
			start_flag=0;
			bus_flag=0;
			slave_address_flag=0;
			repeated_start_flag=0;
			first_start_flag=0;
    	end
   
        if((start_flag==1 || repeated_start_flag==1) && trans.wb_addr == 2'b01)
        begin
      
			slave_address_flag = 1;
			repeated_start_flag = 0;
			start_flag = 0;
			if(trans.wb_data[0] == 0 ) 
			begin
				trans_i2c.i2c_we = WRITE;
			end
			else if (trans.wb_data[0] == 1 ) 
			begin
				trans_i2c.i2c_we = READ;
			end
        	trans.wb_data = trans.wb_data>>1;
        	trans_i2c.i2c_addr = trans.wb_data[6:0];
        end
  
        else if(trans.wb_addr == 2'b01 && slave_address_flag == 1 && stop_flag == 0)  
        begin 
            trans_i2c.i2c_data = {trans_i2c.i2c_data,trans.wb_data};
            first_start_flag = 1;     //Setting first start flag
        end
  
       if(repeated_start_flag == 1 || stop_flag == 1)
        begin
            scoreboard.nb_transport(trans_i2c, transport_trans_i2c); //sendimg transaction to scoreboard
            trans_i2c = new("name");
        end
    endfunction
endclass
