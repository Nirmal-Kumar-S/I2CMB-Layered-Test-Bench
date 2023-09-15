class wb_configuration extends ncsu_configuration;
  
  //calling new function of the parent class
  function new(string name=""); 
    super.new(name);  
  endfunction

  //user defined function to convert to string. Useful to display messages in console
  virtual function string convert2string();
    return {super.convert2string};
  endfunction

endclass

