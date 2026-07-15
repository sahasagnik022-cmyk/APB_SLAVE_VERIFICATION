class apb_monitor;
  apb_transaction mon_tx;
  virtual apb_if.mon vif;
  mailbox #(apb_transaction) mbx;
  
  covergroup cg;
    WRITE: coverpoint mon_tx.PWRITE {bins wr[]={[0:1]};}
    WRDATA: coverpoint mon_tx.PWDATA {
      bins zeros={32'h00000000};
      bins ones={32'hFFFFFFFF};
      bins others=default;
    }
    ADDR: coverpoint mon_tx.PADDR {bins a={[0:31]};}
    STRB: coverpoint mon_tx.PSTRB {bins s[]={[0:15]};}
    ERR: coverpoint mon_tx.PSLVERR {bins e[]={[0:1]};}
    
    WxA: cross WRITE,ADDR;
    STxW: cross STRB,WRITE;
    WxS: cross WRITE,ERR; 
  endgroup
  
  function new(virtual apb_if.mon vif,mailbox #(apb_transaction) mbx);
    this.vif=vif;
    this.mbx=mbx;
    cg=new();
  endfunction
  
  task run();
    $display("[%0t][MON] Monitor Started",$time);
    forever begin
      @(vif.mon_cb);
      if(vif.mon_cb.PSEL==1 && vif.mon_cb.PENABLE == 1) begin
      mon_tx=new();
      mon_tx.PWRITE=vif.mon_cb.PWRITE;
      mon_tx.PADDR=vif.mon_cb.PADDR;
      mon_tx.PSLVERR=vif.mon_cb.PSLVERR;
      mon_tx.PSTRB=vif.mon_cb.PSTRB;
      
      if(mon_tx.PWRITE===1'b1) begin
        mon_tx.PWDATA=vif.mon_cb.PWDATA;
        $display("[%0t][MON] Captured WRITE: Addr=%0d | Wdata=%0d",$time,mon_tx.PADDR,mon_tx.PWDATA);
        cg.sample();
        mbx.put(mon_tx);
      end
      else if(mon_tx.PWRITE===1'b0) begin
        mon_tx.PRDATA=vif.mon_cb.PRDATA;
        $display("[%0t][MON] Captured READ: Addr=%0d | Rdata=%0d",$time,mon_tx.PADDR,mon_tx.PRDATA);
        cg.sample();
        mbx.put(mon_tx);
      end
     end
    end
  endtask
endclass
