`include "apb_defines.svh"
class apb_transaction;
  rand logic [`DATA_WIDTH-1:0] PWDATA;
  rand logic [`ADDR_WIDTH-1:0]  PADDR;
  rand logic [3:0]  PSTRB;
  rand logic  PWRITE;
  rand logic  PSEL;
  rand logic  PENABLE;
  
  logic PSLVERR;
  logic [`DATA_WIDTH-1:0] PRDATA;
  
  virtual function apb_transaction copy();
    apb_transaction cp = new();
    cp.PWDATA  = this.PWDATA;
    cp.PADDR   = this.PADDR;
    cp.PSTRB   = this.PSTRB;
    cp.PWRITE  = this.PWRITE;
    cp.PRDATA  = this.PRDATA;
    cp.PSLVERR = this.PSLVERR;
    cp.PSEL    = this.PSEL;    
    cp.PENABLE = this.PENABLE;
    return cp;
  endfunction
endclass
    
class write_tx extends apb_transaction;
  constraint c_write { PWRITE == 1; }
  constraint c_valid { PSEL == 1; PENABLE == 1; }
  constraint c_addr {PADDR<=256;}
endclass
    
class read_tx extends apb_transaction;
  constraint c_read  { PWRITE == 0; }
  constraint c_valid { PSEL == 1; PENABLE == 1; }
  constraint c_addr {PADDR<=256;}
endclass
    
class error_tx extends apb_transaction;
  constraint c_addr  { PADDR >= 256; }
  constraint c_valid { PSEL == 1; PENABLE == 1; }
endclass


class no_byte_tx extends write_tx;
  constraint c_no_strb { PSTRB == 4'b0000; }
endclass

class full_byte_tx extends write_tx;
  constraint c_full_strb { PSTRB == 4'b1111; }
endclass

class byte_sel_tx extends write_tx;
  constraint c_byte_strb { PSTRB dist {4'b0001 := 1, 4'b0010 := 1, 4'b0100 := 1, 4'b1000 := 1}; }
endclass
