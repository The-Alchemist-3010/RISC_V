module ID (
  input  logic        i_clk           , 
  input  logic        i_reset_n       ,
  input  logic [31:0] i_inst          ,
  input  logic [ 4:0] i_rd            ,
  input  logic        i_reg_wren      ,
  input  logic [31:0] i_rd_data       ,
  output logic        o_a_sel         , 
  output logic        o_b_sel         ,
  output logic [ 3:0] o_alu_sel       ,
  output logic        o_reg_wren      ,
  output logic        o_brun          ,
  output logic        o_mem_wren      ,
  output logic [ 1:0] o_wb_sel        ,
  output logic [ 2:0] o_funct_3       ,
  output logic [31:0] o_rs1_data      , 
  output logic [31:0] o_rs2_data      ,
  output logic [31:0] o_imm           ,
  output logic        o_rs1_hazard_on ,
  output logic        o_rs2_hazard_on
);

  logic [4:0] imm_sel_id;


  ID_REGFILE ID_REGFILE (
    .i_clk         (i_clk         ),
    .i_reset_n     (i_reset_n     ),
    .i_rd_data_id  (i_rd_data     ),
    .i_rd_addr_id  (i_rd          ),
    .i_rd_wren_id  (i_reg_wren    ),
    .i_rs1_addr_id (i_inst[19:15] ),
    .i_rs2_addr_id (i_inst[24:20] ),
    .o_rs1_data_id (o_rs1_data    ),
    .o_rs2_data_id (o_rs2_data    )
  ); 

  ID_IMMGEN ID_IMMGEN (
    .i_instr_id    (i_inst[31:7] ),
    .i_imm_sel_id  (imm_sel_id   ),
    .o_immgen_id   (o_imm        )
  );

  ID_CONTROLLER ID_CONTROLLER (
    .i_inst_id        (i_inst          ),
    .o_imm_sel_id     (imm_sel_id      ),
    .o_alu_sel_id     (o_alu_sel       ),
    .o_reg_wren_id    (o_reg_wren      ),
    .o_brun_id        (o_brun          ),
    .o_a_sel_id       (o_a_sel         ),
    .o_b_sel_id       (o_b_sel         ),
    .o_mem_wren_id    (o_mem_wren      ),
    .o_wb_sel_id      (o_wb_sel        ),
    .o_funct3_id      (o_funct_3       ),
	.o_rs1_hazard_on_id (o_rs1_hazard_on ),
	.o_rs2_hazard_on_id (o_rs2_hazard_on )
  );

endmodule
