class apb_env;
  apb_generator  gen;
  apb_driver     drv;
  apb_monitor    mon;
  apb_scoreboard scb;
  mailbox #(apb_transaction) g2d_mbx;
  mailbox #(apb_transaction) m2s_mbx;
  virtual apb_if vif;
  
  function new(virtual apb_if vif);
    this.vif=vif;
    g2d_mbx=new();
    m2s_mbx=new();
    gen = new(g2d_mbx);
    drv = new(vif.drv, g2d_mbx); 
    mon = new(vif.mon, m2s_mbx); 
    scb = new(m2s_mbx);
  endfunction
  
  task run();

    $display("[ENV] Start Execution");
    fork
      gen.run(); 
      drv.run();
      mon.run();
      scb.run();
    join_any
    while(g2d_mbx.num() > 0) begin
      @(vif.drv_cb); 
    end
    #10;
    scb.report();
    $display("[ENV] Simulation Complete");
    $finish;            
    
  endtask
  
endclass
