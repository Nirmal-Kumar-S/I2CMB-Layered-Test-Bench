class i2c_monitor extends ncsu_component#(.T(i2c_transaction));

    i2c_configuration  configuration;  //handle of I2C config class
    virtual i2c_if i2c_bus;  //declaration of I2C inetrface as virtual
    T monitored_trans;  // handle of transaction class of I2C
    ncsu_component #(i2c_transaction) i2c_agent_monitor;  // handle of agent class of I2C agent

    // calling new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    //user defined class to set config
    function void set_configuration(i2c_configuration cfg);
        configuration = cfg;
    endfunction

    //user defined function to set agent config
    function void set_agent_i2c(ncsu_component#(T) agent_monitor);
        i2c_agent_monitor = agent_monitor;
    endfunction
  
    //run task contains the call to monitor function of I2C interface
    virtual task run ();
        forever 
        begin
            monitored_trans = new("monitored_trans"); 
            i2c_bus.monitor(monitored_trans.i2c_addr, monitored_trans.i2c_we, monitored_trans.i2c_data);
            i2c_agent_monitor.nb_put(monitored_trans);  //put transaction in I2C agent
        end
    endtask

endclass
