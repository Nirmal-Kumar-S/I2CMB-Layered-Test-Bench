class i2cmb_coverage extends ncsu_component#(.T(wb_transaction));

  i2cmb_env_configuration configuration;
  //Register Block
  reg_type reg_access;
  reg_type default_registers;
  we_type WE_type;
  bit [1:0] wb_addr;
  bit [7:0] wb_data;
  bit wb_we;
  bit don_bit;
  bit cmdr_err_flag;
  //FSM byte level 
  cmd_type byte_cmd;
  fsm_byte_state byte_fsm_type;
  //FSM bit level 
  cmd_type bit_cmd;
  fsm_bit_state bit_fsm_type;

// Covergroup for Register Block testing
  covergroup Register_Block;
  option.per_instance = 1;
  option.name = get_full_name();

    // For valid address check
    valid_address_cp : coverpoint wb_addr
    {
      bins Valid_address = {['d0:'d3]}; 
    }
    
    // To check error flag of CMDR
    cmdr_err_flag_cp : coverpoint cmdr_err_flag
    {
      bins ERR_CMDR_FLAG  = {'b1};
    }

    // To verify default values of registers
    default_registers_cp : coverpoint default_registers
    {
      bins RESET_CSR = {'b11000000};
      bins RESET_DPR = {'b00000000};
      bins RESET_CMDR = {'b10000000};
      bins RESET_FSMR = {'b00000000};
    }
    
    wb_data_cp : coverpoint wb_data
    {
      // regs checks by wb_data
      bins CSR_ALIAS  = {'hC0,'hC0,'h0}; 
      bins DPR_ALIAS  = {'hFF,'hFF,'hFF}; 
      bins CMDR_ALIAS = {'h04,'h04,'h04}; 
      bins FSMR_ALIAS = {'h0,'hFF,'h0}; 
    }

    wb_addr_cp : coverpoint wb_addr 
    {
      // regs check by wb_addr
      bins CSR_ADDR_ALIAS  = {'b00}; 
      bins DPR_ADDR_ALIAS  = {'b01}; 
      bins CMDR_ADDR_ALIAS = {'b10};  
      bins FSMR_ADDR_ALIAS = {'b11}; 
    }

    wb_we_cp : coverpoint wb_we 
    {
      // regs check by wb_we
      bins CSR_WE_AL  = {'d1,'d0}; 
      bins DPR_WE_AL  = {'d1,'d0};
      bins CMDR_WE_AL = {'d1,'d0};
      bins FSMR_WE_AL = {'d1,'d0};
    }

    bit_access_aliasing_cp : cross wb_addr_cp,wb_data_cp,wb_we_cp; 
    
    // To check whether all the registers are accessed or not
    reg_access_cp : coverpoint reg_access
    {
      bins CSR = {CSR};
      bins DPR = {DPR};
      bins CMDR = {CMDR};
      bins FSMR = {FSMR};  
    }

    // To ensure both read and write are occcuring
    we_type_cp : coverpoint WE_type
    {
      bins WE_READ = {WE_READ};
      bins WE_WRITE = {WE_WRITE}; 
    } 
  endgroup

// Covergroup for Byte Level FSM
  covergroup Byte_FSM_cg; 
    option.per_instance = 1;
    option.name = get_full_name();

    // Test to check the invalid commands 
    byte_cmd_invalid_cp : coverpoint byte_cmd
    {
      bins INVALID_CMD     = {ST_INVALID};
    }

    // To check what states are covered by the FSM
    fsm_byte_level_valid_cp : coverpoint byte_fsm_type
    {
      bins START_STATE         = {BYTE_FSM_START};
      bins STOP_STATE          = {BYTE_FSM_STOP};
      bins RWACK_STATE         = {BYTE_FSM_READ};
      bins IDLE_STATE          = {BYTE_FSM_IDLE};
      bins WRITE_CMD_STATE     = {BYTE_FSM_WRITE};
      bins SET_BUS_STATE       = {BYTE_FSM_BUS_TAKEN};
      bins WAIT_STATE          = {BYTE_FSM_WAIT};
      bins START_PENDING_STARE = {BYTE_FSM_START_PENDING};
    }

    // To check the invalid states
    fsm_byte_level_invalid_cp: coverpoint byte_fsm_type
    {
      bins INVAILD_FSM_BIT = {4'b1000,4'b1001,4'b1010,4'b1011,4'b1100,4'b1101,4'b1110,4'b1111};
    }

    fsm_start_state_cp : coverpoint byte_fsm_type
    {            
      bins DONE_START    = (BYTE_FSM_START => BYTE_FSM_BUS_TAKEN);
      illegal_bins INVALID_START = (BYTE_FSM_START => BYTE_FSM_STOP, BYTE_FSM_START => BYTE_FSM_START_PENDING, BYTE_FSM_START => BYTE_FSM_READ, BYTE_FSM_START => BYTE_FSM_WRITE, BYTE_FSM_START => BYTE_FSM_WAIT);
    }

    fsm_idle_state_cp : coverpoint byte_fsm_type
    {             
      bins WAIT_IDLE = (BYTE_FSM_IDLE => BYTE_FSM_WAIT);
      bins START_IDLE  = (BYTE_FSM_IDLE => BYTE_FSM_START_PENDING);
      illegal_bins INVALID_IDLE = (BYTE_FSM_IDLE => BYTE_FSM_STOP, BYTE_FSM_IDLE => BYTE_FSM_START, BYTE_FSM_IDLE => BYTE_FSM_READ, BYTE_FSM_IDLE => BYTE_FSM_WRITE, BYTE_FSM_IDLE => BYTE_FSM_BUS_TAKEN);
    }

    fsm_stop_state_cp : coverpoint byte_fsm_type
    {             
      bins DONE_STOP = (BYTE_FSM_STOP => BYTE_FSM_IDLE);
      illegal_bins INVALID_STOP = (BYTE_FSM_STOP => BYTE_FSM_START, BYTE_FSM_STOP => BYTE_FSM_START_PENDING, BYTE_FSM_STOP => BYTE_FSM_READ, BYTE_FSM_STOP => BYTE_FSM_WRITE, BYTE_FSM_STOP => BYTE_FSM_WAIT, BYTE_FSM_STOP => BYTE_FSM_BUS_TAKEN);
    }

    fsm_wait_state_cp : coverpoint byte_fsm_type
    {			  
      bins DONE_WAIT = (BYTE_FSM_WAIT => BYTE_FSM_IDLE);
      illegal_bins INVALID_WAIT = (BYTE_FSM_WAIT => BYTE_FSM_STOP, BYTE_FSM_WAIT => BYTE_FSM_START_PENDING, BYTE_FSM_WAIT => BYTE_FSM_READ, BYTE_FSM_WAIT => BYTE_FSM_WRITE, BYTE_FSM_WAIT => BYTE_FSM_START, BYTE_FSM_WAIT => BYTE_FSM_BUS_TAKEN);
    }

    fsm_bus_taken_state_cp : coverpoint byte_fsm_type
    {        
      bins WRITE_BUS_TAKEN = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_WRITE);
      bins READ_BUS_TAKEN   = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_READ);
      bins START_BUS_TAKEN  = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_START);
      bins STOP_BUS_TAKEN   = (BYTE_FSM_BUS_TAKEN => BYTE_FSM_STOP);
    }

    fsm_write_state_cp : coverpoint byte_fsm_type
    {          
      bins DONE_WITH_ACK   = (BYTE_FSM_WRITE => BYTE_FSM_BUS_TAKEN);
    }

    fsm_read_state_cp : coverpoint byte_fsm_type
    {           
      bins NACK_READ   = (BYTE_FSM_READ => BYTE_FSM_BUS_TAKEN);
    }
  endgroup

// Covergroup for Bit Level FSM 
  covergroup Bit_FSM_cg;
    option.per_instance = 1;
    option.name = get_full_name();

    // To check the invalid commands 
    bit_cmd_invalid_cp : coverpoint bit_cmd
    {
      bins INVALID_CMD     = {ST_INVALID};
    }

    // To check what states are covered by the FSM 
    fsm_bit_level_valid_cp : coverpoint bit_fsm_type
    {
      bins BIT_FSM_IDLE         = {BIT_FSM_IDLE};  
      bins BIT_FSM_START_A      = {BIT_FSM_START_A};   
      bins BIT_FSM_START_B      = {BIT_FSM_START_B};   
      bins BIT_FSM_START_C      = {BIT_FSM_START_C};   
      bins BIT_FSM_RW_A         = {BIT_FSM_RW_A};   
      bins BIT_FSM_RW_B         = {BIT_FSM_RW_B};  
      bins BIT_FSM_RW_C         = {BIT_FSM_RW_C};   
      bins BIT_FSM_RW_D         = {BIT_FSM_RW_D};   
      bins BIT_FSM_RW_E         = {BIT_FSM_RW_E};   
      bins BIT_FSM_STOP_A       = {BIT_FSM_STOP_A};   
      bins BIT_FSM_STOP_B       = {BIT_FSM_STOP_B};   
      bins BIT_FSM_STOP_C       = {BIT_FSM_STOP_C};  
      bins BIT_FSM_RSTART_A     = {BIT_FSM_RSTART_A};   
      bins BIT_FSM_RSTART_B     = {BIT_FSM_RSTART_B};   
      bins BIT_FSM_RSTART_C     = {BIT_FSM_RSTART_C};
    }

    // To check the invalid states
    fsm_bit_level_invalid_cp : coverpoint bit_fsm_type
    {
      bins INVAILD_FSM_BIT = {4'b1111};
    }

    // To check the transition of address signal
    fsm_addr_bit_cp : coverpoint wb_addr
    {
      bins ADDR_TRANS = {2'b11,2'b10};
    }

    // To check the transitions of enable signal     
    fsm_we_bit_cp : coverpoint wb_we
    {
      bins WRITE_ENB_TRANS  = {1'b1,1'b0};
    }
    
    fsm_valid_bit_cp : cross fsm_we_bit_cp, fsm_addr_bit_cp;
  endgroup

  // Covergroup for Testing I2CMB Core Operations
  covergroup I2CMB_Core_Operation_cg;
    option.per_instance = 1;
    option.name         = get_full_name();
    //To check the don bit  
    don_bit_cp : coverpoint don_bit
    {
      bins Don_Bit = {'b1};
    }
    Write_Op_cp                             : coverpoint wb_data
    {
      bins    Write_bin           = {[0:255]} iff(wb_addr == 2'h1); //{[0:31]}
    }
    Read_Op_cp                              : coverpoint wb_data
    {
      bins    Read_bin            = {[0:255]} iff(wb_addr == 2'h1); //{[100:131]}
    }
    RW_Op_cp                                : coverpoint wb_data
    {
      bins    RW_Write_bin        = {[0:255]}  iff (wb_addr == 2'h1); //{[64:127]}
      bins    RW_Read_bin        = {[0:255]}    iff(wb_addr == 2'h1); //{[63:0]}
    }
  endgroup 

  function void set_configuration(i2cmb_env_configuration cfg);
  	configuration = cfg;
  endfunction

  function new(string name = "", ncsu_component_base  parent = null); 
    super.new(name,parent);
    Register_Block = new;  
    Byte_FSM_cg = new;
    Bit_FSM_cg = new;
    I2CMB_Core_Operation_cg = new;
  endfunction

  virtual function void nb_put(T trans);
    if(trans.wb_addr == 'h2) 
    begin
      bit_cmd       = cmd_type'(trans.wb_data[2:0]);
      cmdr_err_flag = (trans.wb_data[4]);
      byte_cmd      = cmd_type'(trans.wb_data);
    end
    
    WE_type = we_type'(trans.wb_we);
    reg_access = reg_type'(trans.wb_addr);
    byte_fsm_type = fsm_byte_state'(trans.wb_data[7:4]);
    bit_fsm_type = fsm_bit_state'(trans.wb_data[3:0]);
    wb_addr = trans.wb_addr;
    wb_data = trans.wb_data;
    wb_we = trans.wb_we;
    don_bit = wb_data[7];

    Register_Block.sample();
    Byte_FSM_cg.sample();
    Bit_FSM_cg.sample();
    I2CMB_Core_Operation_cg.sample();
  endfunction
  
endclass
