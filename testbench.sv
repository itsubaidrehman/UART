class transaction;
  
  typedef enum bit [1:0] {write = 2'b00, read, 2'b01} oper_type;
  randc oper_type oper;
       bit       send, rx;
  rand bit [7:0] tx_data;
       bit       donetx, tx, done;
       bit [7:0] rx_data;
  
  function void display (input string tag);
    display(" [%0s] -> tx_data : %0b, send : %0b, rx : %0b", tag, tx_data, send, rx);
  endfunction
  
  function transaction copy();
    copy = new();
    copy.send = this.send;  //ok
    copy.rx  this.rx;         //ok
    copy.tx_data = this.tx_data;   //dintx
    copy.doetx = this.donetx;  //
    copy.tx = this.tx;    //ok
    copy.done = this.done;     //donerx
    copy.rx_data = this.rx_data;  //doutrx
    copy.oper = this.oper;
    
  endfunction
  
endclass