module EX ( 
  input logic [31:0]  i_pc         ,
  input logic [ 3:0]  i_alu_sel    ,
  input logic [31:0]  i_imm        ,
  input logic         i_brun       ,
  input logic         i_a_sel      , 
  input logic         i_b_sel      ,     
  input logic [31:0]  i_rs1_data   , 
  input logic [31:0]  i_rs2_data   ,
 
  output  logic        o_brlt      ,
  output  logic        o_breq      ,
  output  logic [31:0] o_alu_data     

);
  logic [31:0] data_a_ex, data_b_ex;

  assign data_a_ex = i_a_sel ? i_pc  : i_rs1_data;
  assign data_b_ex = i_b_sel ? i_imm : i_rs2_data;

  EX_ALU EX_ALU (
    .i_operand_a_ex (data_a_ex ),
    .i_operand_b_ex (data_b_ex ),
    .i_alu_op_ex    (i_alu_sel ),
    .o_alu_data_ex  (o_alu_data)
  );

  EX_BRC EX_BRC (
    .i_rs1_data_id (i_rs1_data ),
    .i_rs2_data_id (i_rs2_data ),
    .i_br_un_id    (i_brun     ),
    .o_br_less_id  (o_brlt     ),
    .o_br_equal_id (o_breq     )
  );
endmodule
