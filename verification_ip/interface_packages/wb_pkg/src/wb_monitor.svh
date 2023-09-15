
class wb_monitor extends ncsu_component#(.T(wb_transaction));

    wb_configuration  configuration;  //handle of wishbone config class
    virtual wb_if wb_bus;  //declaring wishbone interface as virtual
    ncsu_component #(T) wb_monitor_agent;  //handle of agent class
    T monitored_trans;  //handle of transcation class

    //calling the new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

    //user defined function to set configuration
    function void set_configuration(wb_configuration cfg);
        configuration = cfg;
    endfunction

    //user defined function to set agent
    function void wb_set_agent(ncsu_component#(wb_transaction) wb_mon_agent);
        wb_monitor_agent = wb_mon_agent;
    endfunction
  
    //run task contains all the activity of monitor
    virtual task run ();
        wb_bus.wait_for_reset();  //calling wait_for_reset function from WB interface
        forever
	    begin
            monitored_trans = new("monitored_trans");  //creating object of monitor class using new
            wb_bus.master_monitor(monitored_trans.wb_addr,monitored_trans.wb_data,monitored_trans.wb_we);   //calling master_monitor function from WB interface
            if(monitored_trans.wb_addr != 'd0)
            begin
                //displaying all the signals from of transaction
                $display("%s wb_monitor::run() Addr: 0x%h Data: 0x%h W/R: 0x%h ",get_full_name(), monitored_trans.wb_addr, monitored_trans.wb_data, monitored_trans.wb_we);
            end
            wb_monitor_agent.nb_put(monitored_trans);  // calling non blocking put method from WB agent class
        end
    endtask
endclass
