class i2cmb_environment extends ncsu_component#(.T(wb_transaction));

    i2cmb_env_configuration configuration;  // handle of env config class
    i2c_agent         i2c_agt;  //handle of I2C agent class
    wb_agent          wb_agt;  // handle of WB agent handle
    i2cmb_predictor   pred;   //handle of predictor class
    i2cmb_scoreboard  scbd;   //handle of scoreboard class
    i2cmb_coverage coverage; //handle of environment coverage class


    //calling new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

   //user defined function to set configuration
    function void set_configuration(i2cmb_env_configuration cfg);
        configuration = cfg;
    endfunction

    //build function contains creating objects of the agents, predictor and scoreboards and call to their build methods
    virtual function void build();
        wb_agt = new("wb_agt",this);
        wb_agt.set_configuration(configuration.wb_agent_config);
        wb_agt.build();
        i2c_agt = new("i2c_agt",this);
        i2c_agt.set_configuration(configuration.i2c_agent_config);
        i2c_agt.build();
        pred  = new("pred", this);
        pred.set_configuration(configuration);
        pred.build();
        scbd  = new("scbd", this);
        scbd.build();
        coverage = new("coverage", this);
        coverage.set_configuration(configuration);
        coverage.build();
        wb_agt.connect_subscriber(coverage);
        //connection predictor to scoreboard
        wb_agt.connect_subscriber(pred);
        pred.set_scoreboard(scbd);
        i2c_agt.connect_subscriber(scbd);
    endfunction

    //function returns the handle of I2C agent
    function ncsu_component #(i2c_transaction) get_i2c_agent();
        return i2c_agt;
    endfunction

    //function returns the handle of WB agent
    function ncsu_component #(wb_transaction) get_wb_agent();
        return wb_agt;
    endfunction

   //run task calls run function present in both the agents
    virtual task run();
        i2c_agt.run();
        wb_agt.run();
    endtask

endclass
