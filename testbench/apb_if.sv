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
    default input #1;
    output PSEL,PWRITE,PENABLE,PWDATA,PADDR,PSTRB;
  endclocking
  
  clocking mon_cb@(posedge PCLK);
    default input #1;
    input PRDATA,PSLVERR,PREADY,PSEL,PWRITE,PENABLE,PWDATA,PADDR,PSTRB;
  endclocking
  
  modport drv(clocking drv_cb,input PCLK,input PRESETn);
  modport mon(clocking mon_cb,input PCLK,input PRESETn);  

endinterface
