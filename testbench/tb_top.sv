import apb_pkg::*;

module tb_top;
  bit PCLK;
  bit PRESETn;
  
  always #5 PCLK = ~PCLK; 

  initial begin
    PCLK = 0;
    PRESETn = 0;    
    #20 PRESETn = 1;  
  end
  
  apb_if vif(PCLK, PRESETn);
  
  apb_slave DUT (
    .PCLK    (PCLK),         
    .PRESETn (PRESETn),        
    .PADDR   (vif.PADDR),
    .PSEL    (vif.PSEL),
    .PENABLE (vif.PENABLE),
    .PWRITE  (vif.PWRITE),
    .PWDATA  (vif.PWDATA),
    .PSTRB   (vif.PSTRB),
    .PRDATA  (vif.PRDATA),
    .PREADY  (vif.PREADY),
    .PSLVERR (vif.PSLVERR)
  );
  test_full test;
  initial begin
    wait(PRESETn == 1);
    test = new(vif);
    test.execute_test();
  end
endmodule
