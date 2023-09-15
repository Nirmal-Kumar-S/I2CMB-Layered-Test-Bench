class ncsu_config_db #(type T) extends ncsu_void;
  static T db[string];
	virtual wb_intf wb_bus;
	virtual i2c_intf i2c_bus;
  static function void set(input string name, input T value);
    db[name] = value;
  endfunction

  static function bit get(input string name, ref T value);
    if ( db.exists(name) ) begin
      value = db[name];
      return 1;
    end else begin
      return 0;
    end
endfunction

endclass
