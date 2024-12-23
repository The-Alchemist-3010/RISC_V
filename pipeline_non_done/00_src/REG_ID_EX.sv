module REG_ID_EX (
  input             i_clk        , 
  input             i_reset_n    , 
  input             i_stall      , 
  input             i_flush      ,
  
  input      [31:0] ID_i_pc      , 
  input      [31:0] ID_i_inst    ,
  input      [31:0] ID_i_data_r1 , 
  input      [31:0] ID_i_data_r2 , 
  input      [31:0] ID_i_imm     ,
  input             ID_i_a_sel   , 
  input             ID_i_b_sel   ,
  input             ID_i_brun    ,
  input      [ 3:0] ID_i_alu_sel ,
  input             ID_i_reg_wren,
  input             ID_i_mem_wren,
  input      [ 1:0] ID_i_wb_sel  ,
  input      [ 2:0] ID_i_funct_3 ,

  output reg [31:0] EX_o_pc      , 
  output reg [31:0] EX_o_inst    ,
  output reg [31:0] EX_o_data_r1 ,
  output reg [31:0] EX_o_data_r2 , 
  output reg [31:0] EX_o_imm     ,
  output reg        EX_o_a_sel   , 
  output reg        EX_o_b_sel   ,
  output reg        EX_o_brun    ,
  output reg [ 3:0] EX_o_alu_sel ,
  output reg        EX_o_reg_wren,
  output reg        EX_o_mem_wren,
  output reg [ 1:0] EX_o_wb_sel  ,
  output reg [ 2:0] EX_o_funct_3
);
  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(~i_reset_n) begin
      EX_o_pc        <= 32'd0;
      EX_o_inst      <= 32'd0;
      EX_o_data_r1   <= 32'd0;
      EX_o_data_r2   <= 32'd0;
      EX_o_imm       <= 32'd0;
      EX_o_a_sel     <= 1'd0 ;
      EX_o_b_sel     <= 1'd0 ;
      EX_o_brun      <= 1'd0 ;
      EX_o_alu_sel   <= 4'd0 ;
      EX_o_reg_wren  <= 1'd0 ;
      EX_o_mem_wren  <= 1'd0 ;
      EX_o_wb_sel    <= 2'd0 ;
      EX_o_funct_3   <= 3'd0 ;
    end else if(i_flush | i_stall) begin
      EX_o_pc        <= 32'd0;
      EX_o_inst      <= 32'd0;
      EX_o_data_r1   <= 32'd0;
      EX_o_data_r2   <= 32'd0;
      EX_o_imm       <= 32'd0;
      EX_o_a_sel     <= 1'd0 ;
      EX_o_b_sel     <= 1'd0 ;
      EX_o_brun      <= 1'd0 ;
      EX_o_alu_sel   <= 4'd0 ;
      EX_o_reg_wren  <= 1'd0 ;
      EX_o_mem_wren  <= 1'd0 ;
      EX_o_wb_sel    <= 2'd0 ;
      EX_o_funct_3   <= 3'd0 ;  
    end else begin
      EX_o_pc        <= ID_i_pc      ;
      EX_o_inst      <= ID_i_inst    ;
      EX_o_data_r1   <= ID_i_data_r1 ;
      EX_o_data_r2   <= ID_i_data_r2 ;
      EX_o_imm       <= ID_i_imm     ;
      EX_o_a_sel     <= ID_i_a_sel   ;
      EX_o_b_sel     <= ID_i_b_sel   ;
      EX_o_brun      <= ID_i_brun    ;
      EX_o_alu_sel   <= ID_i_alu_sel ;
      EX_o_reg_wren  <= ID_i_reg_wren;
      EX_o_mem_wren  <= ID_i_mem_wren;
      EX_o_wb_sel    <= ID_i_wb_sel  ;
      EX_o_funct_3   <= ID_i_funct_3 ;
    end
  end

endmodule
