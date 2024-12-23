module REG_EX_MEM (
  input             i_clk          , 
  input             i_reset_n      ,

  input      [31:0] EX_i_alu_data  ,
  input      [31:0] EX_i_pc        ,
  input      [31:0] EX_i_rs2_data  ,
  input      [31:0] EX_i_inst      ,
  input             EX_i_mem_wren  ,
  input             EX_i_reg_wren  ,
  input      [ 1:0] EX_i_wb_sel    ,
  input      [ 2:0] EX_i_funct_3   ,

  output reg [31:0] MEM_o_alu_data , 
  output reg [31:0] MEM_o_inst     ,
  output reg [31:0] MEM_o_pc       ,
  output reg [31:0] MEM_o_rs2_data ,
  output reg        MEM_o_mem_wren ,
  output reg        MEM_o_reg_wren , 
  output reg [ 1:0] MEM_o_wb_sel   ,
  output reg [ 2:0] MEM_o_funct_3  

);

   always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(~i_reset_n) begin
      MEM_o_pc           <= 32'd0;
      MEM_o_inst         <= 32'd0;
      MEM_o_alu_data     <= 32'd0;
      MEM_o_reg_wren     <= 1'd0 ;
      MEM_o_mem_wren     <= 1'd0 ;
      MEM_o_wb_sel       <= 2'd0 ;
      MEM_o_funct_3      <= 3'd0 ;
      MEM_o_rs2_data     <= 32'd0;
    end else begin
      MEM_o_pc           <= EX_i_pc       ;
      MEM_o_inst         <= EX_i_inst     ;
      MEM_o_alu_data     <= EX_i_alu_data ;
      MEM_o_reg_wren     <= EX_i_reg_wren ;
      MEM_o_mem_wren     <= EX_i_mem_wren ;
      MEM_o_wb_sel       <= EX_i_wb_sel   ;
      MEM_o_funct_3      <= EX_i_funct_3  ;
      MEM_o_rs2_data     <= EX_i_rs2_data ;
		end
	end
endmodule
