class apb_driver;
  apb_transaction drv_tx;
  virtual apb_if.drv vif;
  
  mailbox #(apb_transaction) mbx_gen;
  
  function new(virtual apb_if.drv vif, mailbox #(apb_transaction) mbx_gen);
    this.vif = vif;
    this.mbx_gen = mbx_gen;    
  endfunction
  
  task run();
    wait(vif.PRESETn == 0);
    $display("[%0t] [DRV] Reset Applied", $time);
    vif.drv_cb.PSEL    <= 0;
    vif.drv_cb.PENABLE <= 0;
    vif.drv_cb.PADDR   <= 0;
    vif.drv_cb.PWDATA  <= 0;
    vif.drv_cb.PWRITE  <= 0;
    vif.drv_cb.PSTRB   <= 0;
    wait(vif.PRESETn == 1);
    $display("[%0t] [DRV] Reset Complete", $time);
    forever begin
      mbx_gen.get(drv_tx);
      
      @(vif.drv_cb); 
      vif.drv_cb.PSEL    <= drv_tx.PSEL;
      vif.drv_cb.PENABLE <= drv_tx.PENABLE;
      vif.drv_cb.PADDR   <= drv_tx.PADDR;
      vif.drv_cb.PWRITE  <= drv_tx.PWRITE;
      vif.drv_cb.PSTRB   <= drv_tx.PSTRB;
      
      if (drv_tx.PWRITE) begin
        vif.drv_cb.PWDATA <= drv_tx.PWDATA;
      end else begin
        vif.drv_cb.PWDATA <= 0;
      end
      
      $display("[%0t] [DRV] PSEL=%0d,PENABLE=%0d,PWRITE=%0d to Addr=%0d", $time,drv_tx.PSEL,drv_tx.PENABLE,drv_tx.PWRITE,drv_tx.PADDR);
    end
  endtask
endclass
