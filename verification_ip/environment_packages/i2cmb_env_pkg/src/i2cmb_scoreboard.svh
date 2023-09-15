class i2cmb_scoreboard extends ncsu_component#(.T(i2c_transaction));

    // I2C transaction class handles
    T trans_in;  
    T trans_out;

    //calling new function of parent class
    function new(string name = "", ncsu_component_base parent = null);
        super.new(name,parent);
    endfunction

   //non blocking transfer function to transfer I2C transaction functions
    virtual function void nb_transport(input T input_trans, output T output_trans);
        this.trans_in = input_trans;
        output_trans = trans_out;
    endfunction

    //displaying and comparing the expected and actual transactions
    virtual function void nb_put(T trans);
    	$display(" \n ");
	    $display({get_full_name()," nb_transport: ---------------- EXPECTED TRANSACTION: -------------------\n ",trans_in.convert2string()});
   	    $display({get_full_name()," nb_put: ---------------- ACTUAL TRANSACTION: --------------------- \n",trans.convert2string()});
    	if ( this.trans_in.compare(trans) )
	       $display({get_full_name()," \n ******************** I2C TRANSACTION MATCHED! ******************** \n"});
        else                                
	        $display({get_full_name()," \n ***************** I2C TRANSACTION MISMATCHED! ***************** \n"});
    endfunction


endclass
