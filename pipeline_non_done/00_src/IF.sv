module IF (
  input  logic        i_clk      , 
  input  logic        i_reset_n  ,  
  input  logic        i_stall    ,
  input  logic        i_flush    ,
  input  logic [31:0] i_alu_data ,
  output logic [31:0] o_inst     ,
  output logic [31:0] o_pc      
);

  logic [31: 0] pc_next_if, pc_if, pc_four_if;

  assign o_pc = pc_if ;

  IF_PC IF_PC (
    .i_clk        (i_clk      ),
    .i_reset_n    (i_reset_n  ),
    .i_stall      (i_stall    ),
    .i_pc_next_if (pc_next_if ),
    .o_pc_if      (pc_if      )
  );

  IF_PC_FOUR IF_PC_FOUR (
    .i_pc_if      (pc_if      ),
    .o_pc_four_if (pc_four_if )
  );

  IF_MUX_PC IF_MUX_PC (
    .i_alu_data_if (i_alu_data ),
    .i_pc_four_if  (pc_four_if ),
    .i_flush       (i_flush    ),
    .o_pc_next_if  (pc_next_if )
  );

  IF_INST_MEM IF_INST_MEM (
    .i_pc_if   (pc_if ),
    .o_inst_if (o_inst)
  );
endmodule
