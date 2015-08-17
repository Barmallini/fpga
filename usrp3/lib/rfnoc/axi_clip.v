

// Copyright 2014, Ettus Research

module axi_clip
  #(parameter WIDTH_IN=24,
    parameter WIDTH_OUT=16,
    parameter FIFOSIZE=1)  // FIFOSIZE=1, single output register
   (input clk, input reset,
    input [WIDTH_IN-1:0] i_tdata, input i_tlast, input i_tvalid, output i_tready,
    output [WIDTH_OUT-1:0] o_tdata, output o_tlast, output o_tvalid, input o_tready);

   wire overflow = |i_tdata[WIDTH_IN-1:WIDTH_OUT-1] & ~(&i_tdata[WIDTH_IN-1:WIDTH_OUT-1]);

   wire [WIDTH_OUT-1:0] out = overflow ? 
                        (i_tdata[WIDTH_IN-1] ? {1'b1,{(WIDTH_OUT-1){1'b0}}} : {1'b0,{(WIDTH_OUT-1){1'b1}}}) :
                        i_tdata[WIDTH_OUT-1:0];

   generate
     if (FIFOSIZE == 0) begin
       assign o_tdata = out;
       assign o_tlast = i_tlast;
       assign o_tvalid = i_tvalid;
       assign i_tready = o_tready;
     end else begin
       axi_fifo #(.WIDTH(WIDTH_OUT+1), .SIZE(FIFOSIZE)) flop
         (.clk(clk), .reset(reset), .clear(1'b0),
          .i_tdata({i_tlast, out}), .i_tvalid(i_tvalid), .i_tready(i_tready),
          .o_tdata({o_tlast, o_tdata}), .o_tvalid(o_tvalid), .o_tready(o_tready),
          .occupied(), .space());
     end
   endgenerate

endmodule // clip
