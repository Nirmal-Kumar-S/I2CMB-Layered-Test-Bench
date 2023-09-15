class wb_agent extends ncsu_component#(.T(wb_transaction));

    wb_configuration configuration;  //handle of WB config class
    wb_driver        driver;  //handle of WB driver class
    wb_monitor       monitor;  //hanlde of WB monitor class

    ncsu_component #(T) subscribers[$];   //a queue to store transactions
    virtual wb_if    wb_bus;  // declaration of WB interface as virtual

    //calling new function of the parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
        if ( !(ncsu_config_db#(virtual wb_if)::get(get_full_name(), this.wb_bus)))  //check if the virtual interface handle if present in config_db
	    begin
            $display("wb_agent::ncsu_config_db::get() call for BFM handle failed for name: %s ",get_full_name());
        end
    endfunction

    //user defined function to set configuration
    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    //user defined funtion to build driver, monitor and to set configuration of driver and monitor
    virtual function void build();
        driver = new("driver",this);  //creating object of driver class
        driver.set_configuration(configuration);  //setting config of driver
        driver.build();
        driver.wb_bus = this.wb_bus;
        monitor = new("monitor",this);  //creating object of monitor
        monitor.wb_set_agent(this);  //setting config of monitor
        monitor.set_configuration(configuration);
        monitor.build();
        monitor.wb_bus = this.wb_bus;
    endfunction

    //non blocking put function to put transaction into the queue
    virtual function void nb_put(T trans);
        foreach (subscribers[i]) subscribers[i].nb_put(trans);
    endfunction

    //function to put transactions in driver
    virtual task bl_put(T trans);
        driver.bl_put(trans);
    endtask

    //to store transactions in the subscriber queue
    virtual function void connect_subscriber(ncsu_component#(T) subscriber);
       subscribers.push_back(subscriber);
    endfunction

    //run task contains a call to run function in WB monitor class
    virtual task run();
        fork 
	        monitor.run(); 
        join_none
    endtask

endclass
