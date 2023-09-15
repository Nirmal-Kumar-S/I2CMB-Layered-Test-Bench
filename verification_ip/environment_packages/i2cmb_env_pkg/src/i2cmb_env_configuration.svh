class i2cmb_env_configuration extends ncsu_configuration;

  i2c_configuration i2c_agent_config;  //handle of I2C agent config
  wb_configuration wb_agent_config;   //handle of WB agent config

  //calling new function of the parent class
  function new(string name="");
    super.new(name);
    i2c_agent_config = new("i2c_agent_config");  //creating object of I2C agent config
    wb_agent_config = new("wb_agent_config");  //creating object of WB agent config
  endfunction
endclass
