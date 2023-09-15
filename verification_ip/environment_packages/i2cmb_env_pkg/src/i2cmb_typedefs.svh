   typedef enum bit [1:0] {CSR='b00, DPR='b01, CMDR='b10, FSMR='b11} reg_type;

   typedef enum bit [2:0] { ST_START_CMD='b100, ST_STOP_CMD='b101, ST_READ_ACK_CMD='b010, ST_READ_NAK_CMD='b011, ST_WRITE_CMD='b001, ST_SET_BUS_CMD='b110, ST_WAIT_CMD='b000, ST_INVALID='b111 } cmd_type;
 
   typedef enum bit {WE_READ='b0, WE_WRITE='b1} we_type;

   typedef enum bit [3:0] { BIT_FSM_IDLE        = 4'b0000,
                            BIT_FSM_START_A     = 4'b0001, 
                            BIT_FSM_START_B     = 4'b0010, 
                            BIT_FSM_START_C     = 4'b0011, 
                            BIT_FSM_RW_A        = 4'b0100, 
                            BIT_FSM_RW_B        = 4'b0101, 
                            BIT_FSM_RW_C        = 4'b0110, 
                            BIT_FSM_RW_D        = 4'b0111, 
                            BIT_FSM_RW_E        = 4'b1000, 
                            BIT_FSM_STOP_A      = 4'b1001, 
                            BIT_FSM_STOP_B      = 4'b1010, 
                            BIT_FSM_STOP_C      = 4'b1011, 
                            BIT_FSM_RSTART_A    = 4'b1100, 
                            BIT_FSM_RSTART_B    = 4'b1101,
                            BIT_FSM_RSTART_C    = 4'b1110 
   } fsm_bit_state;

  typedef enum bit [3:0] {  BYTE_FSM_IDLE            = 'b0000,
                            BYTE_FSM_BUS_TAKEN       = 'b0001,
                            BYTE_FSM_START_PENDING   = 'b0010,
                            BYTE_FSM_START           = 'b0011,
                            BYTE_FSM_STOP            = 'b0100,
                            BYTE_FSM_WRITE           = 'b0101,
                            BYTE_FSM_READ            = 'b0110,
                            BYTE_FSM_WAIT            = 'b0111
   } fsm_byte_state;