module REG_MEM_WB (
  input             i_clk          , 
  input             i_reset_n      ,

  input      [31:0] MEM_i_pc       ,
  input      [31:0] MEM_i_inst     ,
  input      [31:0] MEM_i_alu_data ,
  input      [31:0] MEM_i_lsu_data ,
  input      [ 1:0] MEM_i_wb_sel   ,
  input             MEM_i_reg_wren ,

  output reg [31:0] WB_o_pc       ,
  output reg [31:0] WB_o_inst     ,
  output reg [31:0] WB_o_alu_data ,
  output reg [31:0] WB_o_lsu_data ,
  output reg [ 1:0] WB_o_wb_sel   ,
  output reg        WB_o_reg_wren
);

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(~i_reset_n) begin
      WB_o_lsu_data       <= 32'd0;
      WB_o_reg_wren       <= 1'd0 ;
      WB_o_pc             <= 32'd0;
      WB_o_alu_data       <= 32'd0;
      WB_o_wb_sel         <= 2'd0 ;
      WB_o_inst           <= 32'd0;
    end else begin
      WB_o_lsu_data       <= MEM_i_lsu_data;
      WB_o_reg_wren       <= MEM_i_reg_wren;
      WB_o_pc             <= MEM_i_pc      ;
      WB_o_alu_data       <= MEM_i_alu_data;
      WB_o_wb_sel         <= MEM_i_wb_sel  ;
      WB_o_inst           <= MEM_i_inst    ;
    end
  end

endmodule
