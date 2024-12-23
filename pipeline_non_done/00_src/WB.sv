module WB (
  input  [31:0] i_pc        ,
  input  [31:0] i_alu_data  ,
  input  [31:0] i_lsu_data  ,
  input  [ 1:0] i_wb_sel    ,
  output [31:0] o_rd_data
);

  assign o_rd_data = (i_wb_sel == 2'b01) ? i_alu_data : (i_wb_sel == 2'b10) ? (i_pc + 4) : i_lsu_data;

endmodule
