class i2cmb_test extends ncsu_component#(.T(i2c_transaction));

    i2cmb_env_configuration  cfg;  //handle of environment config class
    i2cmb_environment        env;  // handle of environment
    i2cmb_generator          gen;  //handle of generator
   
    //calling new function of parent class and creating objects of above declared handles
    function new(string name = "", ncsu_component_base  parent = null);
        super.new(name,parent);
        cfg = new("cfg");
        env = new("env",this);
        env.set_configuration(cfg);
        env.build();
        gen = new("gen",this);
        gen.i2c_set_agent(env.get_i2c_agent());
        gen.wb_set_agent(env.get_wb_agent());
    endfunction

    //calling run function of environment and generator
    virtual task run();
       env.run();
       gen.run();
    endtask

endclass

