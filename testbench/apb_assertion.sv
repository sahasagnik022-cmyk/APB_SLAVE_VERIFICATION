module apb_assertion (
  input logic PCLK,
  input logic PRESETn,
  input logic PSEL,
  input logic PENABLE,
  input logic PWRITE,
  input logic [31:0] PADDR,
  input logic [3:0] PSTRB,
  input logic PREADY,
  input logic PSLVERR
);
  property p_pslverr_valid;
    @(posedge PCLK) disable iff (!PRESETn)
    PSLVERR |-> (PSEL && PENABLE && PREADY);
  endproperty

  PSLVERR_VALID: assert property(p_pslverr_valid)
    else $error("[%0t] SVA FAIL: PSLVERR asserted outside of Access Phase", $time);

endmodule
