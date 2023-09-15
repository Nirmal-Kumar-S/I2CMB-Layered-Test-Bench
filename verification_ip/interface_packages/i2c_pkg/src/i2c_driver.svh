class i2c_driver extends ncsu_component#(.T(i2c_transaction));

    i2c_configuration configuration;  //handle of I2C config class
    i2c_transaction i2c_trans;  //handle of I2C transaction class
    virtual i2c_if i2c_bus;  //declaring I2C interface as virtual
    bit [7:0] i2c_read_data [], i=0, j=0, checkpoint=0;

    //calling new function of the parent class
    function new(string name = "", ncsu_component_base parent = null);
      super.new(name,parent);
    endfunction

    //functiom to set config
    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    //blocking put method to put I2C transactions in the I2C interface
    virtual task bl_put(T trans);
        $display({get_full_name()," ",trans.convert2string()});
        forever
        begin
            i2c_bus.wait_for_i2c_transfer(trans.i2c_we,trans.i2c_data);

            if(trans.i2c_we == READ) //if Read operation
            begin
                i2c_read_data = new [1];

                if(checkpoint < 32 ) 
                begin
                    i2c_read_data [0] = (100+i);
                    i++;
                    i2c_bus.provide_read_data(i2c_read_data);
                    checkpoint++;
                end

                else if(checkpoint>=32)
                begin 
                    i2c_read_data [0] = (63-j); 
                    i2c_bus.provide_read_data(i2c_read_data);
                    j++;
                end
            end
        end
    endtask

endclass
