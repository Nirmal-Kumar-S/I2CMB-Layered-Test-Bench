class wb_transaction extends ncsu_transaction;
   
    `ncsu_register_object(wb_transaction)  //factory registration of "wb_transaction" class

    //declaration of some useful signals
    rand bit [1:0] wb_addr;  
    rand bit [7:0] wb_data;
    bit wb_we;
    bit wb_wait_for_irq;

    //call to new function of parent class
    function new(string name="");
        super.new(name);
    endfunction

    //user defined function for conversion to string. Useful while displaying on console
    virtual function string convert2string();
        return {super.convert2string(),$sformatf(" WB Address:0x%h Data:0x%h WE:0x%h ", wb_addr,wb_data,wb_we)};
    endfunction

    //user defined compare function to be used in scoreboard for transaction comparison
    function bit compare(wb_transaction rhs);
        return ((this.wb_addr  == rhs.wb_addr ) && (this.wb_data == rhs.wb_data) && (this.wb_we == rhs.wb_we));
    endfunction
endclass
