class apb_scoreboard;
  apb_transaction tx; 
  mailbox #(apb_transaction) mbx;
  logic [31:0] ref_mem [int];
  logic [31:0] exp_data;
  function new(mailbox #(apb_transaction) mbx);
    this.mbx=mbx;
  endfunction
  int pass_count=0;
  int fail_count=0;
  task run();
    $display("[SCB] Scoreboard started");
    forever begin
      mbx.get(tx);
      if(tx.PWRITE==1) begin
        $display("[%0t][SCB] Write transaction to Ref Model at Addr=%0d",$time,tx.PADDR);
        if(!ref_mem.exists(tx.PADDR)) begin
          ref_mem[tx.PADDR]=32'h00000000;
        end
        for (int i = 0; i < 4; i++) begin
          if (tx.PSTRB[i]) begin
            ref_mem[tx.PADDR][8*i +: 8] = tx.PWDATA[8*i +: 8];
          end
        end
      end
      else begin
        $display("[%0t][SCB] Read Transaction from Ref Model at Addr=%0d",$time,tx.PADDR);
        if(ref_mem.exists(tx.PADDR)) begin
          exp_data=ref_mem[tx.PADDR];
        end
        else begin
          exp_data=32'h00000000;
        end
        if (tx.PSLVERR == 1) begin
            pass_count++;
            $display("[%0t] [SCB] PASS! Out-of-bounds Addr=%0d", $time, tx.PADDR);
        end
        else if(tx.PRDATA === exp_data) begin
          $display("[%0t]][SCB] PASS! Addr=%0d | Actual=%0d| Exp Data=%0d| PSLVERR=%0d",$time,tx.PADDR, tx.PRDATA,exp_data,tx.PSLVERR);
          pass_count++;
        end
        else if(tx.PRDATA!== exp_data) begin
          $error("[%0t][SCB] FAIL! Addr=%0d | Actual=%0d | Exp Data=%0d| PSLVERR=%0d",$time,tx.PADDR, tx.PRDATA, exp_data,tx.PSLVERR);
          fail_count++;
        end
        
      end
    end
  endtask
  function void report();
    $display("=================================================");
    $display("              SCOREBOARD FINAL REPORT            ");
    $display("=================================================");
    $display(" Total Read Transactions Checked : %0d", pass_count + fail_count);
    $display(" Total PASS                      : %0d", pass_count);
    $display(" Total FAIL                      : %0d", fail_count);
    $display("=================================================");
  endfunction
endclass
