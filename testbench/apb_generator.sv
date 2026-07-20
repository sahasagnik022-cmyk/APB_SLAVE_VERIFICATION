class apb_generator;
  mailbox #(apb_transaction) mbx;
  function new(mailbox #(apb_transaction) mbx);
    this.mbx = mbx;
  endfunction

  task run_b2b_write(int num);
    write_tx wr_tx;
    $display("\n[GEN] Back to Back Write Test: %0d ---", num);
    for(int i=0; i<num; i++) begin
      wr_tx = new();
      if(!wr_tx.randomize()) $fatal(1, "Randomization failed");
      mbx.put(wr_tx);
      $display("[%0t] [GEN] Tx %0d | WRITE | Addr=%0d | Data=%0d | Strobe=%0b", $time, i, wr_tx.PADDR, wr_tx.PWDATA, wr_tx.PSTRB);
    end
  endtask

  task run_b2b_read(int num);
    read_tx rd_tx;
    $display("\n[GEN] Back to Back Read Test: %0d ---", num);
    for(int i=0; i<num; i++) begin
      rd_tx = new();
      if(!rd_tx.randomize()) $fatal(1, "Randomization failed");
      mbx.put(rd_tx);
      $display("[%0t] [GEN] Tx %0d | READ  | Addr=%0d | Strobe=%0b", $time,i, rd_tx.PADDR, rd_tx.PSTRB);
    end
  endtask

  // Feature ID 10, 11
  task run_write_read(int count=5);
    write_tx wr_tx;
    read_tx rd_tx;
    $display("\n[GEN] Write followed by Read");
    for(int i=0;i<count;i++) begin
    wr_tx = new();
    if(!wr_tx.randomize()) $fatal(1,"Randomization failed");
    mbx.put(wr_tx);
    $display("[%0t] [GEN] Write | Addr=%0d | Data=%0d | PSTRB=%0b", $time,wr_tx.PADDR,wr_tx.PWDATA,wr_tx.PSTRB);

    rd_tx = new();
    if(!rd_tx.randomize()) $fatal(1,"Randomization failed");
    rd_tx.PADDR = wr_tx.PADDR;
    mbx.put(rd_tx);
    $display("[%0t] [GEN] Read | from Addr=%0d",$time,rd_tx.PADDR);
    end
  endtask

  // Feature 6
  task run_byte_test();
    byte_sel_tx byte_tx;
    $display("\n[GEN] Byte Select Test ");
    for(int i=0; i<50; i++) begin
        byte_tx = new();
        if(!byte_tx.randomize()) $fatal(1,"Randomization failed");
        mbx.put(byte_tx);
        $display("[%0t] [GEN] Tx %0d | WRITE | Addr=%0d | Data=%0d | Strobe=%0b", $time, i, byte_tx.PADDR, byte_tx.PWDATA, byte_tx.PSTRB);
    end
  endtask

  // Feature 7
  task run_full_byte_test();
    full_byte_tx fb_tx;
    $display("\n[GEN] Full Byte Select Test");
    fb_tx = new();
    if(!fb_tx.randomize()) $fatal(1,"Randomization failed");
    mbx.put(fb_tx);
    $display("[%0t] [GEN] WRITE | Addr=%0d | Strobe=%0b", $time, fb_tx.PADDR, fb_tx.PSTRB);
  endtask

  // Feature 8
  task run_no_byte_test();
    no_byte_tx nb_tx;
    $display("\n[GEN] No Byte Select Test ");
    nb_tx = new();
    if(!nb_tx.randomize()) $fatal(1,"Randomization failed");
    mbx.put(nb_tx);
    $display("[%0t] [GEN] WRITE | Addr=%0d | Strobe=%0b", $time, nb_tx.PADDR, nb_tx.PSTRB);
  endtask

  // Feature 14
  task run_error_test();
    error_tx err_tx;
    $display("\n[GEN] Error Check (Out of Bounds)");
    for(int i=0;i<10; i++) begin
      err_tx = new();
      if(!err_tx.randomize()) $fatal(1, "Randomization failed");
      mbx.put(err_tx);
      $display("[%0t] [GEN] Tx %0d | Addr=%0d (Expected Error)", $time,i, err_tx.PADDR);
    end
  endtask

  // MAIN TASK
  task run();
    $display("[GEN] STARTING FULL TEST");
    run_b2b_write(50);
    run_byte_test();
    run_full_byte_test();
    run_no_byte_test();
    run_write_read(50);
    run_b2b_read(50);
    run_error_test();
    $display("[GEN] FULL TEST COMPLETED");
  endtask

endclass
