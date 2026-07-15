import apb_pkg::*;
module tb_top;
  bit PCLK;
  bit PRESETn;

  // Generate a 100MHz Clock (10ns period)
  always #5 PCLK = ~PCLK; 

  initial begin
    PCLK = 0;
    PRESETn = 0;      // Assert active-low reset
    #20 PRESETn = 1;  // De-assert reset after 20 time units
  end

  // ==========================================
  // 2. Interface Instantiation
  // ==========================================
  apb_if vif(PCLK, PRESETn);

  // ==========================================
  // 3. DUT Instantiation (RTL)
  // ==========================================
  // We map the physical ports of your Verilog module to the interface wires.
  // (Assuming your RTL module is named 'apb_slave')
  apb_slave DUT (
    .PCLK    (PCLK),           // Or vif.PCLK
    .PRESETn (PRESETn),        // Or vif.PRESETn
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

  // ==========================================
  // 4. Environment Execution
  // ==========================================
  apb_test test;

  initial begin
    // Instantiate the test and pass it the virtual interface
    test = new(vif);
    
    // Kick off the test!
    test.run();
  end
  initial begin
    $dumpfile("dump.vcd"); 
    $dumpvars(0, tb_top);
  end

endmodule
