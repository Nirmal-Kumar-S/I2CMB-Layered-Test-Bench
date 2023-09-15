class i2c_configuration extends ncsu_configuration;

  //calling new function of the parent class
  function new(string name=""); 
    super.new(name);
  endfunction

  // convert to string function for displaying to console
  virtual function string convert2string();
    return {super.convert2string};
  endfunction

endclass
