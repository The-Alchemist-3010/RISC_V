module IF_PC(
    input               i_clk        ,
    input               i_reset_n    ,
    input               i_stall      ,
    input reg  [31:0]   i_pc_next_if ,
    output reg [31:0]   o_pc_if     
);
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(~i_reset_n) begin
      o_pc_if = 32'b0        ;
    end else if(i_stall) begin
      o_pc_if = o_pc_if      ;
    end else begin
      o_pc_if = i_pc_next_if ;
    end
  end
endmodule

