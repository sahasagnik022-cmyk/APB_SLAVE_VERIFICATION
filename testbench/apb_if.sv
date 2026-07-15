`include "apb_defines.svh"

interface apb_if(input bit PCLK ,input bit PRESETn);
  logic [`DATA_WIDTH-1:0] PWDATA;
  logic [`ADDR_WIDTH-1:0] PADDR;
  logic PSEL;
  logic PENABLE;
  logic PWRITE;
  logic [3:0] PSTRB;
  logic [`DATA_WIDTH:0] PRDATA;
  logic PSLVERR;
  logic PREADY;
  
  clocking drv_cb@(posedge PCLK);
    default input #1 output #1;
    output PSEL,PWRITE,PENABLE,PWDATA,PADDR,PSTRB;
  endclocking
  
  clocking mon_cb@(posedge PCLK);
    default input #1 output #1;
    input PRDATA,PSLVERR,PREADY,PSEL,PWRITE,PENABLE,PWDATA,PADDR,PSTRB;
  endclocking
  
  modport drv(clocking drv_cb,input PCLK,input PRESETn);
  modport mon(clocking mon_cb,input PCLK,input PRESETn);  
//Assertions
  // Feature 1
  property p_addr_stable;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE) |-> $stable(PADDR);
  endproperty
  assert_addr_stable: assert property(p_addr_stable) 
    else $error("[SVA] APB Protocol Violation: PADDR changed during transfer!");

  // Feature 2
  property p_strb_stable;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PWRITE) |-> $stable(PSTRB);
  endproperty
  assert_strb_stable: assert property(p_strb_stable)
    else $error("[SVA] APB Protocol Violation: PSTRB changed during Write!");

  // Feature 4
  property p_write_stable;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE) |-> $stable(PWRITE);
  endproperty
  assert_write_stable: assert property(p_write_stable)
    else $error("[SVA] APB Protocol Violation: PWRITE changed during transfer!");

  // Feature 3
  property p_slverr_check;
    @(posedge PCLK) disable iff (!PRESETn)
    (PSEL && PENABLE && PADDR > 255) |-> PSLVERR;
  endproperty
  assert_slverr_check: assert property(p_slverr_check)
    else $error("[SVA] RTL Bug: PSLVERR did not assert for out-of-bounds PADDR!");

endinterface
