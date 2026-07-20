import apb_pkg::*;
//`include "apb_assertion.sv"
module tb_top;
  bit PCLK;
  bit PRESETn;
  always #5 PCLK = ~PCLK;
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
  bind apb_slave apb_assertion sva_inst (
    .PCLK(PCLK),
    .PRESETn(PRESETn),
    .PSEL(PSEL),
    .PENABLE(PENABLE),
    .PWRITE(PWRITE),
    .PADDR(PADDR),
    .PSTRB(PSTRB),
    .PREADY(PREADY),
    .PSLVERR(PSLVERR)
  );

  apb_test test;

  initial begin
    PCLK = 0;
    PRESETn = 0; 
    #1;
    $display("[%0t] RST PRDATA=%0d | PREADY=%0d | PSLVERR=%0d",$time,vif.PRDATA,vif.PREADY,vif.PSLVERR);
    #20;
    PRESETn = 1; 
    test = new(vif);
    test.run();
  end
endmodule
