class apb_test;
  apb_env env;
  virtual apb_if vif;
  function new(virtual apb_if vif);
    this.vif = vif;
  endfunction

  task run();
    env = new(vif);
    env.run();
  endtask

endclass

/*
class apb_test;
  apb_env env;
  virtual apb_if vif;
  
  function new(virtual apb_if vif);
    this.vif = vif; 
    env = new(vif);
  endfunction
  
  virtual task run();
  endtask
  
  task execute_test();
    env.run();
    this.run(); 
    while(env.g2d_mbx.num() > 0) begin
      @(env.vif.drv_cb); 
    end
    #10;
    env.scb.report();
    $display("[TEST] Simulation Complete");
    $finish;            
  endtask
endclass 

class test_b2b_write extends apb_test; 
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  
  task run(); 
    write_tx wr_tx;
    int count = 5; 
    $display("[TEST] Back to Back Write ");
    for(int i=0;i<count;i++) begin
      wr_tx = new();
      if(!wr_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(wr_tx);
      $display("[%0t] [TEST] Tx %0d | WRITE | Addr=%0d | Data=%0d | Strobe=%0b", 
               $time, i, wr_tx.PADDR, wr_tx.PWDATA, wr_tx.PSTRB);
    end
  endtask
endclass

class test_b2b_read extends apb_test; 
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  
  task run();
    read_tx rd_tx;
    int count = 5; 
    $display("[TEST] Back to Back Read "); 
    for(int i=0;i<count;i++) begin
      rd_tx = new();
      if(!rd_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(rd_tx); 
      $display("[%0t] [TEST] Tx %0d | READ  | Addr=%0d | Strobe=%0b",$time, i, rd_tx.PADDR, rd_tx.PSTRB);
    end
  endtask
endclass

class test_write_read extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  
  task run(); 
    write_tx wr_tx;
    read_tx  rd_tx;
    int count = 5; 
    $display("[TEST] Write followed by Read");
    for(int i=0; i<count; i++) begin
      wr_tx = new();
      if(!wr_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(wr_tx);
      $display("[%0t] [TEST] Write | Addr=%0d | Data=%0d | PSTRB=%0b", $time,wr_tx.PADDR,wr_tx.PWDATA,wr_tx.PSTRB);
      
      rd_tx = new();
      if(!rd_tx.randomize() with {PADDR==wr_tx.PADDR;}) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(rd_tx);
      $display("[%0t] [TEST] Read  | from Addr=%0d",$time,rd_tx.PADDR);
    end
  endtask
endclass

class test_byte_sel extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  
  task run();
    byte_sel_tx byte_tx;
    $display("[TEST] Byte Select Test ");
    for(int i=0; i<10; i++) begin
        byte_tx = new();
        if(!byte_tx.randomize()) $fatal(1,"Randomization failed");
        env.g2d_mbx.put(byte_tx);
        $display("[%0t] [TEST] Tx %0d | WRITE | Addr=%0d | Data=%0d | Strobe=%0b", $time, i, byte_tx.PADDR, byte_tx.PWDATA, byte_tx.PSTRB);
    end
  endtask
endclass

class test_full_byte extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  
  task run();
    full_byte_tx fb_tx;
    $display("\n[TEST] Full Byte Select Test");
    fb_tx = new();
    if(!fb_tx.randomize()) $fatal(1,"Randomization failed");
    env.g2d_mbx.put(fb_tx);
    $display("[%0t] [TEST] WRITE | Addr=%0d | Strobe=%0b", $time, fb_tx.PADDR, fb_tx.PSTRB);
  endtask
endclass

class test_no_byte extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction

  task run();
    no_byte_tx nb_tx;
    $display("[TEST] No Byte Select Test ");
    nb_tx = new();
    if(!nb_tx.randomize()) $fatal(1,"Randomization failed");
    env.g2d_mbx.put(nb_tx); // FIXED: Changed gen2drv_mbx to g2d_mbx
    $display("[%0t] [TEST] WRITE | Addr=%0d | Strobe=%0b", $time, nb_tx.PADDR, nb_tx.PSTRB);
  endtask
endclass

class test_error extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction

  task run();
    error_tx err_tx;
    $display("[TEST] Error Check (Out of Bounds)");
    for(int i=0;i<3; i++) begin
      err_tx = new();
      if(!err_tx.randomize()) $fatal(1, "Randomization failed");
      env.g2d_mbx.put(err_tx);
      $display("[%0t] [TEST] Tx %0d | Addr=%0d (Expected Error)", $time,i, err_tx.PADDR);
    end
  endtask
endclass

class test_full extends apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction

  task run();
    test_b2b_write  t1 = new(env.vif);
    test_byte_sel   t2 = new(env.vif);
    test_full_byte  t3 = new(env.vif);
    test_no_byte    t4 = new(env.vif);
    test_write_read t5 = new(env.vif);
    test_b2b_read   t6 = new(env.vif);
    test_error      t7 = new(env.vif);

    t1.env = this.env; 
    t2.env = this.env; 
    t3.env = this.env; 
    t4.env = this.env; 
    t5.env = this.env; 
    t6.env = this.env; 
    t7.env = this.env;
    
    $display("[TEST] START FULL TEST");
    t1.run(); 
    t2.run(); 
    t3.run(); 
    t4.run();
    t5.run(); 
    t6.run(); 
    t7.run();
    $display("[TEST] FULL TEST COMPLETED");
  endtask
endclass*/
