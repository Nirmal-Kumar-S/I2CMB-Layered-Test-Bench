class i2c_agent extends ncsu_component#(.T(i2c_transaction));

    i2c_configuration configuration;  //handle of I2C config class
    i2c_driver        driver;  //handle of I2C driver class
    i2c_monitor       monitor;  //handle of I2C monitor
    ncsu_component #(T) subscribers[$];  //queue to store I2C transactions
    virtual i2c_if i2c_bus;  //declaring I2C interface as virtual

    //calling new method of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        if ( !(ncsu_config_db#(virtual i2c_if)::get(get_full_name(), this.i2c_bus)))   //checking if the I2C handle is present in config_db
        begin
            $display("i2c_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
        end
    endfunction

    //function to set configuation
    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    // functions that creates objects of monitor and driver and set their configurations
    virtual function void build();
        driver = new("driver",this); //to create driver object
        driver.set_configuration(configuration);  //to set configuration of driver
        driver.build();
        driver.i2c_bus = this.i2c_bus;
        monitor = new("monitor",this);  //to create monitor object
        monitor.set_agent_i2c(this);  
        monitor.set_configuration(configuration);  //to set configuration of monitor
        monitor.build();
        monitor.i2c_bus = this.i2c_bus;
    endfunction

    // non blocking put function to put transaction in subscriber queue
    virtual function void nb_put(T trans);
        foreach (subscribers[i]) subscribers[i].nb_put(trans);
    endfunction

    //blocking put method to put transaction in driver
    virtual task bl_put(T trans);
        driver.bl_put(trans);
    endtask

    //to store transaction in the subscriber queue
    virtual function void connect_subscriber(ncsu_component #(T) subscriber);
        subscribers.push_back(subscriber);
    endfunction

    //run task contains a call to the I2C monitor
    virtual task run();
        fork 
	        monitor.run();
	    join_none
    endtask

endclass
