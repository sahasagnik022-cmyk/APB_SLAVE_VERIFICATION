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

class test_b2b_write apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  task run(int count);
    write_tx wr_tx;
    for(int i=0;i<count;i++) begin
      wr_tx=new();
      if(!wr_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(wr_tx);
      $display("[%0t] [TEST] Tx %0d | WRITE | Addr=%0d | Data=%0d | Strobe=%0b", 
               $time, i, wr_tx.PADDR, wr_tx.PWDATA, wr_tx.PSTRB);
    end
  endtask
endclass

class test_b2b_read apb_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  task run(int count);
    read_tx wr_tx;
    for(int i=0;i<count;i++) begin
      wr_tx=new();
      if(!rd_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(wr_tx);
      $display("[%0t] [TEST] Tx %0d | READ | Addr=%0d | Data=%0d | Strobe=%0b", 
               $time, i, rd_tx.PADDR, rd_tx.PWDATA, rd_tx.PSTRB);
    end
  endtask
endclass

class test_write_read extends apb_base_test;
  function new(virtual apb_if vif);
    super.new(vif);
  endfunction
  task run(int count);
    write_tx wr_tx;
    read_tx  rd_tx;
    $display("\n[TEST] Write followed by Read");
    for(int i=0; i<count; i++) begin
      wr_tx = new();
      if(!wr_tx.randomize()) $fatal(1,"Randomization failed");
      env.g2d_mbx.put(wr_tx);
      rd_tx = new();
      if(!rd_tx.randomize()) $fatal(1,"Randomization failed");
      rd_tx.PADDR = wr_tx.PADDR; 
      env.g2d_mbx.put(rd_tx);
    end
  endtask
endclass


  
