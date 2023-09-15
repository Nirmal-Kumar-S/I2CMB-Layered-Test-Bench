class i2cmb_generator extends ncsu_component#(.T(ncsu_transaction));

  i2c_transaction i2c_trans[20];
  wb_transaction  wb_trans_read_single_byte[15], wb_trans_write_32_bytes[107], wb_trans_write_single_byte[14], wb_trans_write_fsmr[20], wb_trans[20];
  wb_transaction start_array[2], slave_address_array[3], write_array[3], stop_array[2], ack_trans_array[3], nack_trans_array[3];
  ncsu_component #(i2c_transaction) i2c_handle;
  ncsu_component #(wb_transaction) wb_handle;
  string trans_name;
  bit [7:0] wb_read_data;
  bit [7:0] temp_slave_addr;
  int i=0,o=0;

  function new(string name = "", ncsu_component_base parent = null);
    super.new(name,parent);
    if (!$value$plusargs("GEN_TRANS_TYPE=%s", trans_name)) 
    begin
      $display("FATAL: +GEN_TRANS_TYPE plusarg not found on command line");
      $fatal;
    end
    $display("%m found +GEN_TRANS_TYPE=%s", trans_name);
  endfunction

  virtual task run();
    fork
    begin
      for (int l = 0; l < 107; l++)
      begin
        $cast(wb_trans_write_32_bytes[l],ncsu_object_factory::create(trans_name));
      end

      //Writing 32 Bytes
      $display("\n/********************* Writing 32 Bytes ********************/\n");
      wb_write_32_bytes('h22,'h00);
      foreach(wb_trans_write_32_bytes[k])
      begin
        wb_handle.bl_put(wb_trans_write_32_bytes[k]);
      end

      //Reading 32 Bytes
      $display("\n/********************* Reading 32 Bytes ********************/\n");
      for (int p = 0; p < 15; p++)
      begin
        $cast(wb_trans_read_single_byte[p],ncsu_object_factory::create(trans_name));
      end

      for (int x = 0; x < 32; x++) 
      begin
        wb_read_1_byte('h22,wb_read_data);
        foreach(wb_trans_read_single_byte[q])
        begin
          wb_handle.bl_put(wb_trans_read_single_byte[q]);
        end
      end

      for (int y = 0; y < 4; y++) 
      begin
        for (int m = 0; m < 14; m++)
        begin
          $cast(wb_trans_write_single_byte[m],ncsu_object_factory::create(trans_name));
        end
        wb_write_1_byte('h22,(64+y));

        foreach(wb_trans_write_single_byte[o])
        begin
          wb_handle.bl_put(wb_trans_write_single_byte[o]);
        end
        wb_read_1_byte('h22,wb_read_data);

        foreach(wb_trans_read_single_byte[i])
        begin
          assert (wb_trans_write_32_bytes[i].randomize());
          wb_handle.bl_put(wb_trans_read_single_byte[i]);
        end
      end

      for (int m = 0; m < 25; m++)
      begin
        $cast(wb_trans_write_fsmr[m],ncsu_object_factory::create(trans_name));
      end
      
      wb_trans_write_fsmr[o].wb_addr  = 'b00;   wb_trans_write_fsmr[o].wb_data  = 'b11000000;   wb_trans_write_fsmr[o].wb_we  = 'b1; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b00;   wb_trans_write_fsmr[o].wb_data  = 'b11111111;   wb_trans_write_fsmr[o].wb_we  = 'b1; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b01;   wb_trans_write_fsmr[o].wb_data  = 'b11111111;   wb_trans_write_fsmr[o].wb_we  = 'b1; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b10;   wb_trans_write_fsmr[o].wb_data  = 'b11111111;   wb_trans_write_fsmr[o].wb_we  = 'b1; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b11;   wb_trans_write_fsmr[o].wb_data  = 'b11111111;   wb_trans_write_fsmr[o].wb_we  = 'b1; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b00;                                                   wb_trans_write_fsmr[o].wb_we  = 'b0; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b01;                                                   wb_trans_write_fsmr[o].wb_we  = 'b0; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b10;                                                   wb_trans_write_fsmr[o].wb_we  = 'b0; o++;
      wb_trans_write_fsmr[o].wb_addr  = 'b11;                                                   wb_trans_write_fsmr[o].wb_we  = 'b0; o++;

      foreach(wb_trans_write_fsmr[o])
      begin
        wb_handle.bl_put(wb_trans_write_fsmr[o]);
      end
      o=0;

      for (int m = 0; m < 25; m++)
      begin
        $cast(wb_trans[m],ncsu_object_factory::create(trans_name));
      end
      //providing STOP command to CMDR
      wb_trans[o].wb_addr   = 'b00;   wb_trans[o].wb_data   = 'b11000000;     wb_trans[o].wb_we   = 'b1; o++;
      wb_trans[o].wb_addr   = 'b10;   wb_trans[o].wb_data   = 'bxxxxx101;     wb_trans[o].wb_we   = 'b1; wb_trans[o].wb_wait_for_irq = 'b1; o++; 
      wb_trans[o].wb_addr   = 'b10;                                           wb_trans[o].wb_we   = 'b0; wb_trans[o].wb_wait_for_irq = 'b1; o++; 

      foreach(wb_trans_write_fsmr[k])
      begin
        wb_handle.bl_put(wb_trans_write_fsmr[k]);
      end

      //FSMR reg checks 
      $display("\n/********************* FSMR Test ********************/\n");

      for (int m = 0; m < 14; m++)
      begin
        $cast(wb_trans_write_fsmr[m],ncsu_object_factory::create(trans_name));
      end
      wb_write_fsmr('h22, 64);

      foreach(wb_trans_write_fsmr[o])
      begin
        wb_handle.bl_put(wb_trans_write_fsmr[o]);
      end

      //Repeated starts check
      $display("\n/********************* Start and Repeated Start Conditions *****************/\n");
      wb_start_initial();
      $display("\n/Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_write_initial('h01);
      wb_start_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_write_initial('h02);
      wb_slave_addr_initial('h45);
      wb_write_initial('h03);
      wb_start_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_read_ack();
      wb_start_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_read_nack();
      wb_stop_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_read_nack();
      wb_stop_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_read_nack();
      wb_stop_initial();
      $display("\n/Repeated Start Condition/\n");
      wb_slave_addr_initial('h44);
      wb_read_nack();
      wb_stop_initial();
      $display("\n/Stop Condition/\n");
      wb_stop_initial();
      $display("\n/Stop Condition/\n");
      wb_stop_initial();
    end

    begin
      forever
      begin
        foreach(i2c_trans[k]) 
        begin
          $cast(i2c_trans[k],ncsu_object_factory::create("i2c_transaction"));
          i2c_handle.bl_put(i2c_trans[k]);
        end 
      end
    end
    join_any
  endtask 
  //******************************************** Tests End Here *************************************************


  //********************************************* Function Definations Here *************************************************

  task wb_write_1_byte(input bit [7:0] slave_addr_w, input bit [7:0] wb_write_data);

    wb_trans_write_single_byte[0].wb_addr   = 'b00;   wb_trans_write_single_byte[0].wb_data   = 'b11000000;       wb_trans_write_single_byte[0].wb_we   = 'b1;
    wb_trans_write_single_byte[1].wb_addr   = 'b01;   wb_trans_write_single_byte[1].wb_data   = 'b00000001;       wb_trans_write_single_byte[1].wb_we   = 'b1;
    wb_trans_write_single_byte[2].wb_addr   = 'b10;   wb_trans_write_single_byte[2].wb_data   = 'bxxxxx110;       wb_trans_write_single_byte[2].wb_we   = 'b1;
    wb_trans_write_single_byte[3].wb_addr   = 'b10;                                                               wb_trans_write_single_byte[3].wb_we   = 'b0;  wb_trans_write_single_byte[3].wb_wait_for_irq = 'b1;
    wb_trans_write_single_byte[4].wb_addr   = 'b10;   wb_trans_write_single_byte[4].wb_data   = 'bxxxxx100;       wb_trans_write_single_byte[4].wb_we   = 'b1;
    wb_trans_write_single_byte[5].wb_addr   = 'b10;                                                               wb_trans_write_single_byte[5].wb_we   = 'b0;  wb_trans_write_single_byte[5].wb_wait_for_irq = 'b1;
    wb_trans_write_single_byte[6].wb_addr   = 'b01;   wb_trans_write_single_byte[6].wb_data   = slave_addr_w<<1;  wb_trans_write_single_byte[6].wb_we   = 'b1;
    wb_trans_write_single_byte[7].wb_addr   = 'b10;   wb_trans_write_single_byte[7].wb_data   = 'bxxxxx001;       wb_trans_write_single_byte[7].wb_we   = 'b1;
    wb_trans_write_single_byte[8].wb_addr   = 'b10;                                                               wb_trans_write_single_byte[8].wb_we   = 'b0;  wb_trans_write_single_byte[8].wb_wait_for_irq = 'b1;
    wb_trans_write_single_byte[9].wb_addr   = 'b01;   wb_trans_write_single_byte[9].wb_data   = wb_write_data;    wb_trans_write_single_byte[9].wb_we   = 'b1;  
    wb_trans_write_single_byte[10].wb_addr  = 'b10;   wb_trans_write_single_byte[10].wb_data  = 'bxxxxx001;       wb_trans_write_single_byte[10].wb_we  = 'b1;
    wb_trans_write_single_byte[11].wb_addr  = 'b10;                                                               wb_trans_write_single_byte[11].wb_we  = 'b0;  wb_trans_write_single_byte[11].wb_wait_for_irq = 'b1;
    wb_trans_write_single_byte[12].wb_addr  = 'b10;   wb_trans_write_single_byte[12].wb_data  = 'bxxxxx101;       wb_trans_write_single_byte[12].wb_we  = 'b1;
    wb_trans_write_single_byte[13].wb_addr  = 'b10;                                                               wb_trans_write_single_byte[13].wb_we  = 'b0;  wb_trans_write_single_byte[13].wb_wait_for_irq = 'b1;
  endtask : wb_write_1_byte


  task wb_write_32_bytes(input bit [7:0] slave_addr_w, input bit [7:0] wb_write_data);

    wb_trans_write_32_bytes[i].wb_addr   = 'b00;       wb_trans_write_32_bytes[i].wb_data   = 'b11000000;       wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b01;   wb_trans_write_32_bytes[i].wb_data   = 'b00000001;       wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx110;       wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                            wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx100;       wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                            wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b01;   wb_trans_write_32_bytes[i].wb_data   = slave_addr_w<<1;  wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx001;       wb_trans_write_32_bytes[i].wb_we   = 'b1;
    for (int j = 0; j < 4; j++) 
    begin
      i++;wb_trans_write_32_bytes[i].wb_addr = 'b10;                                                          wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
      i++;wb_trans_write_32_bytes[i].wb_addr = 'b01;   wb_trans_write_32_bytes[i].wb_data   = j;              wb_trans_write_32_bytes[i].wb_we   = 'b1;  
      i++;wb_trans_write_32_bytes[i].wb_addr = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx001;     wb_trans_write_32_bytes[i].wb_we   = 'b1;
    end
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                        wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx101;   wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                        wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
    
    //WAIT
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b01;   wb_trans_write_32_bytes[i].wb_data   = 'b00000101;     wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'b00000000;     wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                          wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx111;     wb_trans_write_32_bytes[i].wb_we   = 'b1;

    // STOP
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx101;     wb_trans_write_32_bytes[i].wb_we   = 'b1;
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;                                                          wb_trans_write_32_bytes[i].wb_we   = 'b0; wb_trans_write_32_bytes[i].wb_wait_for_irq = 'b1;

    //Invalid to CMDR
    i++;wb_trans_write_32_bytes[i].wb_addr   = 'b10;   wb_trans_write_32_bytes[i].wb_data   = 'bxxxxx111;     wb_trans_write_32_bytes[i].wb_we   = 'b1;

  endtask : wb_write_32_bytes


  task wb_read_1_byte(input bit [7:0] slave_addr_r, output bit [7:0] wb_read_data);
    
    temp_slave_addr = slave_addr_r<<1;
    temp_slave_addr = temp_slave_addr + 'b1;
    wb_trans_read_single_byte[0].wb_addr   = 'b00;   wb_trans_read_single_byte[0].wb_data   = 'b11000000;       wb_trans_read_single_byte[0].wb_we   = 'b1; wb_trans_read_single_byte[0].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[1].wb_addr   = 'b01;   wb_trans_read_single_byte[1].wb_data   = 'b00000001;       wb_trans_read_single_byte[1].wb_we   = 'b1; wb_trans_read_single_byte[1].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[2].wb_addr   = 'b10;   wb_trans_read_single_byte[2].wb_data   = 'bxxxxx110;       wb_trans_read_single_byte[2].wb_we   = 'b1; wb_trans_read_single_byte[2].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[3].wb_addr   = 'b10;                                                              wb_trans_read_single_byte[3].wb_we   = 'b0; wb_trans_read_single_byte[3].wb_wait_for_irq  = 'b1;
    wb_trans_read_single_byte[4].wb_addr   = 'b10;   wb_trans_read_single_byte[4].wb_data   = 'bxxxxx100;       wb_trans_read_single_byte[4].wb_we   = 'b1; wb_trans_read_single_byte[4].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[5].wb_addr   = 'b10;                                                              wb_trans_read_single_byte[5].wb_we   = 'b0; wb_trans_read_single_byte[5].wb_wait_for_irq  = 'b1;
    wb_trans_read_single_byte[6].wb_addr   = 'b01;   wb_trans_read_single_byte[6].wb_data   = temp_slave_addr;  wb_trans_read_single_byte[6].wb_we   = 'b1; wb_trans_read_single_byte[6].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[7].wb_addr   = 'b10;   wb_trans_read_single_byte[7].wb_data   = 'bxxxxx001;       wb_trans_read_single_byte[7].wb_we   = 'b1; wb_trans_read_single_byte[7].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[8].wb_addr   = 'b10;                                                              wb_trans_read_single_byte[8].wb_we   = 'b0; wb_trans_read_single_byte[8].wb_wait_for_irq  = 'b1;
    wb_trans_read_single_byte[9].wb_addr   = 'b10;   wb_trans_read_single_byte[9].wb_data   = 'b00000011;       wb_trans_read_single_byte[9].wb_we   = 'b1; wb_trans_read_single_byte[9].wb_wait_for_irq  = 'b0;
    wb_trans_read_single_byte[10].wb_addr  = 'b10;                                                              wb_trans_read_single_byte[10].wb_we  = 'b0; wb_trans_read_single_byte[10].wb_wait_for_irq = 'b1;
    wb_trans_read_single_byte[11].wb_addr  = 'b01;   wb_trans_read_single_byte[11].wb_data  = wb_read_data;     wb_trans_read_single_byte[11].wb_we  = 'b0; wb_trans_read_single_byte[11].wb_wait_for_irq = 'b0;
    wb_trans_read_single_byte[12].wb_addr  = 'b10;   wb_trans_read_single_byte[12].wb_data  = 'bxxxxx101;       wb_trans_read_single_byte[12].wb_we  = 'b1; wb_trans_read_single_byte[12].wb_wait_for_irq = 'b0;
    wb_trans_read_single_byte[13].wb_addr  = 'b10;                                                              wb_trans_read_single_byte[13].wb_we  = 'b0; wb_trans_read_single_byte[13].wb_wait_for_irq = 'b1;
    
  endtask 


  task wb_write_fsmr(input bit [7:0] slave_addr_w, input bit [7:0] wb_write_data);

    i=0;
    wb_trans_write_fsmr[i].wb_addr   = 'b00;       wb_trans_write_fsmr[i].wb_data   = 'b11000000;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b01;   wb_trans_write_fsmr[i].wb_data   = 'b00000001;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;   wb_trans_write_fsmr[i].wb_data   = 'bxxxxx110;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;                                                      wb_trans_write_fsmr[i].wb_we   = 'b0; wb_trans_write_fsmr[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;   wb_trans_write_fsmr[i].wb_data   = 'bxxxxx100;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;                                                      wb_trans_write_fsmr[i].wb_we   = 'b0; wb_trans_write_fsmr[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b01;   wb_trans_write_fsmr[i].wb_data   = slave_addr_w<<1;wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;   wb_trans_write_fsmr[i].wb_data   = 'bxxxxx001;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    for (int j = 0; j < 1; j++) begin
      i++;wb_trans_write_fsmr[i].wb_addr = 'b10;                                                      wb_trans_write_fsmr[i].wb_we   = 'b0; wb_trans_write_fsmr[i].wb_wait_for_irq = 'b1;
      i++;wb_trans_write_fsmr[i].wb_addr = 'b11;   wb_trans_write_fsmr[i].wb_data   = j;              wb_trans_write_fsmr[i].wb_we   = 'b1;  //data byte
      i++;wb_trans_write_fsmr[i].wb_addr = 'b10;   wb_trans_write_fsmr[i].wb_data   = 'bxxxxx001;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    end
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;                                                      wb_trans_write_fsmr[i].wb_we   = 'b0; wb_trans_write_fsmr[i].wb_wait_for_irq = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;   wb_trans_write_fsmr[i].wb_data   = 'bxxxxx101;     wb_trans_write_fsmr[i].wb_we   = 'b1;
    i++;wb_trans_write_fsmr[i].wb_addr   = 'b10;                                                      wb_trans_write_fsmr[i].wb_we   = 'b0; wb_trans_write_fsmr[i].wb_wait_for_irq = 'b1;
    
  endtask : wb_write_fsmr

  virtual task wb_start_initial();
    foreach (start_array[j]) 
    begin  
      $cast(start_array[j],ncsu_object_factory::create(trans_name));
    end
    //start command to CMDR
    start_array[0].wb_addr= 2'b10; start_array[0].wb_data= 8'bxxxxx100; start_array[0].wb_we=1'b1; start_array[0].wb_wait_for_irq=1'b0; 
    //wait for I2C to read CMDR
    start_array[1].wb_addr= 2'b10; start_array[1].wb_we=1'b0; start_array[1].wb_wait_for_irq=1'b1; 
    foreach (start_array[j]) 
    begin  
      wb_handle.bl_put(start_array[j]);
    end
  endtask: wb_start_initial

  virtual task wb_stop_initial();
  foreach (stop_array[j]) 
  begin  
    $cast(stop_array[j],ncsu_object_factory::create(trans_name));
  end
  //provide START command to CMDR reg
  stop_array[0].wb_addr= 2'b10; stop_array[0].wb_data= 8'bxxxxx101; stop_array[0].wb_we=1'b1; stop_array[0].wb_wait_for_irq=1'b0;
  //wait for I2C to read CMDR
  stop_array[1].wb_addr= 2'b10; stop_array[1].wb_we=1'b0; stop_array[1].wb_wait_for_irq=1'b1; 
  foreach (stop_array[j]) 
  begin  
    wb_handle.bl_put(stop_array[j]);
  end
  endtask: wb_stop_initial

  virtual task wb_slave_addr_initial(bit[7:0] slave_address);
  foreach (slave_address_array[j]) 
  begin  
    $cast(slave_address_array[j],ncsu_object_factory::create(trans_name));
  end
  //provide slave address to DPR reg
  slave_address_array[0].wb_addr= 2'b01; slave_address_array[0].wb_data= slave_address ; slave_address_array[0].wb_we=1'b1; slave_address_array[0].wb_wait_for_irq=1'b0;
  //write command to CMDR 
  slave_address_array[1].wb_addr= 2'b10; slave_address_array[1].wb_data= 8'bxxxxx001; slave_address_array[1].wb_we=1'b1; slave_address_array[0].wb_wait_for_irq=1'b0;
  //read CMDR
  slave_address_array[2].wb_addr= 2'b10; slave_address_array[2].wb_we=1'b0; slave_address_array[2].wb_wait_for_irq=1'b1;
  foreach (slave_address_array[j]) 
  begin  
    wb_handle.bl_put(slave_address_array[j]);
  end
  endtask: wb_slave_addr_initial
  
  virtual task wb_write_initial(bit[7:0] write_wb_data);
  foreach (write_array[j]) 
  begin  
    $cast(write_array[j],ncsu_object_factory::create(trans_name));
  end
  //provide slave address to DPR reg
  write_array[0].wb_addr= 2'b01; write_array[0].wb_data= write_wb_data ; write_array[0].wb_we=1'b1; write_array[0].wb_wait_for_irq=1'b0;  
  //write command to CMDR 
  write_array[1].wb_addr= 2'b10; write_array[1].wb_data= 8'bxxxxx001; write_array[1].wb_we=1'b1; write_array[0].wb_wait_for_irq=1'b0;
  //read CMDR
  write_array[2].wb_addr= 2'b10; write_array[2].wb_we=1'b0; write_array[2].wb_wait_for_irq=1'b1; 
  foreach (write_array[j]) 
  begin  
    wb_handle.bl_put(write_array[j]);
  end
  endtask: wb_write_initial

  virtual task wb_read_ack();
  foreach (ack_trans_array[j]) 
  begin  
    $cast(ack_trans_array[j],ncsu_object_factory::create(trans_name));
  end
  //provide slave address to DPR reg
  ack_trans_array[0].wb_addr= 2'b10; ack_trans_array[0].wb_data= 8'bxxxxx010; ack_trans_array[0].wb_we=1'b1; ack_trans_array[0].wb_wait_for_irq=1'b0; 
  //write command to CMDR 
  ack_trans_array[1].wb_addr= 2'b10; ack_trans_array[1].wb_we=1'b0; ack_trans_array[1].wb_wait_for_irq=1'b1; 
  //read CMDR
  ack_trans_array[2].wb_addr= 2'b01; ack_trans_array[2].wb_we=1'b0; ack_trans_array[2].wb_wait_for_irq=1'b0; 
  foreach (ack_trans_array[j]) 
  begin  
    wb_handle.bl_put(ack_trans_array[j]);
  end
  endtask: wb_read_ack

  virtual task wb_read_nack();
  foreach (nack_trans_array[j]) 
  begin  
    $cast(nack_trans_array[j],ncsu_object_factory::create(trans_name));
  end
  //provide slave address to DPR reg
  nack_trans_array[0].wb_addr= 2'b10; nack_trans_array[0].wb_data= 8'bxxxxx011; nack_trans_array[0].wb_we=1'b1; nack_trans_array[0].wb_wait_for_irq=1'b0; 
  //write command to CMDR
  nack_trans_array[1].wb_addr= 2'b10; nack_trans_array[1].wb_we=1'b0; nack_trans_array[1].wb_wait_for_irq=1'b1; 
  //read CMDR
  nack_trans_array[2].wb_addr= 2'b01; nack_trans_array[2].wb_we=1'b0; nack_trans_array[2].wb_wait_for_irq=1'b0; 
  foreach (nack_trans_array[j]) 
  begin  
    wb_handle.bl_put(nack_trans_array[j]);
  end
  endtask: wb_read_nack

  function void wb_set_agent(ncsu_component #(wb_transaction) wb_handle);
    this.wb_handle = wb_handle;
  endfunction

  function void i2c_set_agent(ncsu_component #(i2c_transaction) i2c_handle);
    this.i2c_handle = i2c_handle;
  endfunction
endclass
