module singlecycle (
  input  logic        i_clk     ,
  input  logic        i_rst_n   ,
  output logic [31:0] o_io_ledr ,
  output logic [31:0] o_io_ledg ,
  input  logic [31:0] i_io_sw   ,
  output logic [ 6:0] o_io_hex0 ,
  output logic [ 6:0] o_io_hex1 ,
  output logic [ 6:0] o_io_hex2 ,
  output logic [ 6:0] o_io_hex3 ,
  output logic [ 6:0] o_io_hex4 ,
  output logic [ 6:0] o_io_hex5 ,
  output logic [ 6:0] o_io_hex6 ,
  output logic [ 6:0] o_io_hex7 ,
  output logic [31:0] o_io_lcd  ,
  output reg   [31:0] o_pc_debug,
  output reg          o_insn_vld
);
  
  logic [31: 0] inst_MEM;
  logic  brlt_EX, breq_EX, reg_wren_WB, flush_HZ, stall_HZ;
  logic [31: 0] alu_data_EX, inst_IF, pc_IF, alu_data_MEM, alu_data_WB;
  logic [31: 0] inst_ID, pc_ID, rs1_data_ID, rs2_data_ID, imm_ID;
  logic a_sel_ID, b_sel_ID, reg_wren_ID, brun_ID, mem_wren_ID, rs1_hazard_on_ID, rs2_hazard_on_ID;
  logic [ 1: 0] wb_sel_ID, wb_sel_EX, wb_sel_MEM, wb_sel_WB;
  logic [ 2: 0] funct_3_ID, funct_3_EX, funct_3_MEM, funct_3_WB;
  logic [ 3: 0] alu_sel_ID, alu_sel_EX ;
  
  logic [31: 0] pc_EX, pc_MEM, inst_EX, rs1_data_EX, rs2_data_EX,imm_EX, rs2_data_MEM, lsu_data_MEM,lsu_data_WB, pc_WB, rs2_data_WB;
  logic a_sel_EX, b_sel_EX, brun_EX, reg_wren_EX, mem_wren_EX, mem_wren_MEM, reg_wren_MEM, mem_wren_WB;

  logic [31: 0] inst_WB, rd_data_WB; 

  always_ff @(posedge i_clk) begin
		o_pc_debug <= pc_WB;	
  end

  logic [ 3: 0] i_io_btn;

  HAZARD_DETECT HAZARD_DETECT (
    .EX_inst         (inst_EX          ), 
    .ID_inst         (inst_ID          ),
	  .MEM_inst        (inst_MEM         ),
	  .EX_reg_wren     (reg_wren_EX      ),
	  .MEM_reg_wren    (reg_wren_MEM     ),
    .EX_brlt         (brlt_EX          ), 
    .EX_breq         (breq_EX          ),
	  .ID_rs1_hazard_on(rs1_hazard_on_ID ),
	  .ID_rs2_hazard_on(rs2_hazard_on_ID ),
    .o_flush         (flush_HZ         ),
    .o_stall         (stall_HZ         )
  );

  IF IF (
    .i_clk      (i_clk       ), 
    .i_reset_n  (i_rst_n     ),  
    .i_stall    (stall_HZ    ),
    .i_flush    (flush_HZ    ),
    .i_alu_data (alu_data_EX ),
    .o_inst     (inst_IF     ),
    .o_pc       (pc_IF       )  
  );

  REG_IF_ID REG_IF_ID (
    .i_clk     (i_clk    ), 
    .i_reset_n (i_rst_n  ), 
    .i_flush   (flush_HZ ),
    .i_stall   (stall_HZ ),
    .IF_i_inst (inst_IF  ), 
    .IF_i_pc   (pc_IF    ),
    .ID_o_inst (inst_ID  ), 
    .ID_o_pc   (pc_ID    )
  );

  ID ID (
    .i_clk      (i_clk         ), 
    .i_reset_n  (i_rst_n       ),
    .i_inst     (inst_ID       ),
    .i_rd       (inst_WB[11:7] ),
    .i_reg_wren (reg_wren_WB   ),
    .i_rd_data  (rd_data_WB    ),

    .o_a_sel         (a_sel_ID         ), 
    .o_b_sel         (b_sel_ID         ),
    .o_alu_sel       (alu_sel_ID       ),
    .o_reg_wren      (reg_wren_ID      ),
    .o_brun          (brun_ID          ),
    .o_mem_wren      (mem_wren_ID      ),
    .o_wb_sel        (wb_sel_ID        ),
    .o_funct_3       (funct_3_ID       ),
    .o_rs1_data      (rs1_data_ID      ), 
    .o_rs2_data      (rs2_data_ID      ),
    .o_imm           (imm_ID           ),
   	.o_rs1_hazard_on (rs1_hazard_on_ID ),
	  .o_rs2_hazard_on (rs2_hazard_on_ID )
  );

  REG_ID_EX REG_ID_EX (
    .i_clk         (i_clk       ), 
    .i_reset_n     (i_rst_n     ), 
    .i_stall       (stall_HZ    ), 
    .i_flush       (flush_HZ    ),
  
    .ID_i_pc       (pc_ID       ), 
    .ID_i_inst     (inst_ID     ),
    .ID_i_data_r1  (rs1_data_ID ), 
    .ID_i_data_r2  (rs2_data_ID ), 
    .ID_i_imm      (imm_ID      ),
    .ID_i_a_sel    (a_sel_ID    ), 
    .ID_i_b_sel    (b_sel_ID    ),
    .ID_i_brun     (brun_ID     ),
    .ID_i_alu_sel  (alu_sel_ID  ),
    .ID_i_reg_wren (reg_wren_ID ),
    .ID_i_mem_wren (mem_wren_ID ),
    .ID_i_wb_sel   (wb_sel_ID   ),
    .ID_i_funct_3  (funct_3_ID  ),

    .EX_o_pc       (pc_EX       ), 
    .EX_o_inst     (inst_EX     ),
    .EX_o_data_r1  (rs1_data_EX ),
    .EX_o_data_r2  (rs2_data_EX ), 
    .EX_o_imm      (imm_EX      ),
    .EX_o_a_sel    (a_sel_EX    ), 
    .EX_o_b_sel    (b_sel_EX    ),
    .EX_o_brun     (brun_EX     ),
    .EX_o_alu_sel  (alu_sel_EX  ),
    .EX_o_reg_wren (reg_wren_EX ),
    .EX_o_mem_wren (mem_wren_EX ),
    .EX_o_wb_sel   (wb_sel_EX   ),
    .EX_o_funct_3  (funct_3_EX  )
  );

  EX EX (
    .i_pc       (pc_EX       ),
    .i_alu_sel  (alu_sel_EX  ),
    .i_imm      (imm_EX      ),
    .i_brun     (brun_EX     ),
    .i_a_sel    (a_sel_EX    ), 
    .i_b_sel    (b_sel_EX    ),     
    .i_rs1_data (rs1_data_EX ), 
    .i_rs2_data (rs2_data_EX ),
 
    .o_brlt     (brlt_EX     ),
    .o_breq     (breq_EX     ),
    .o_alu_data (alu_data_EX )   
  );

  REG_EX_MEM REG_EX_MEM (
    .i_clk          (i_clk        ), 
    .i_reset_n      (i_rst_n      ),

    .EX_i_alu_data  (alu_data_EX  ),
    .EX_i_pc        (pc_EX        ),
    .EX_i_rs2_data  (rs2_data_EX  ),
    .EX_i_inst      (inst_EX      ),
    .EX_i_mem_wren  (mem_wren_EX  ),
    .EX_i_reg_wren  (reg_wren_EX  ),
    .EX_i_wb_sel    (wb_sel_EX    ),
    .EX_i_funct_3   (funct_3_EX   ),

    .MEM_o_alu_data (alu_data_MEM ), 
    .MEM_o_inst     (inst_MEM     ),
    .MEM_o_pc       (pc_MEM       ),
    .MEM_o_rs2_data (rs2_data_MEM ),
    .MEM_o_mem_wren (mem_wren_MEM ),
    .MEM_o_reg_wren (reg_wren_MEM ), 
    .MEM_o_wb_sel   (wb_sel_MEM   ),
    .MEM_o_funct_3  (funct_3_MEM  )
  );

  MEM MEM (
    .i_clk         (i_clk        ),
    .i_reset_n     (i_rst_n      ),

    .i_addr        (alu_data_MEM ),
    .i_rs2_data    (rs2_data_MEM ),
    .i_mem_wren    (mem_wren_MEM ),
    .i_mem_funct_3 (funct_3_MEM  ),
 
    .o_lsu_data    (lsu_data_MEM ),

    .o_io_ledr     (o_io_ledr    ),     
    .o_io_ledg     (o_io_ledg    ),     
    .o_io_hex0     (o_io_hex0    ),     
    .o_io_hex1     (o_io_hex1    ),     
    .o_io_hex2     (o_io_hex2    ),     
    .o_io_hex3     (o_io_hex3    ),     
    .o_io_hex4     (o_io_hex4    ),     
    .o_io_hex5     (o_io_hex5    ),     
    .o_io_hex6     (o_io_hex6    ),     
    .o_io_hex7     (o_io_hex7    ),    
    .o_io_lcd      (o_io_lcd     ),      
    .i_io_sw       (i_io_sw      ),    
    .i_io_btn      (i_io_btn     )
  );
  REG_MEM_WB REG_MEM_WB (
    .i_clk          (i_clk        ), 
    .i_reset_n      (i_rst_n      ),

    .MEM_i_pc       (pc_MEM       ),
    .MEM_i_inst     (inst_MEM     ),
    .MEM_i_alu_data (alu_data_MEM ),
    .MEM_i_lsu_data (lsu_data_MEM ),
    .MEM_i_wb_sel   (wb_sel_MEM   ),
    .MEM_i_reg_wren (reg_wren_MEM ),

    .WB_o_pc        (pc_WB        ),
    .WB_o_inst      (inst_WB      ),
    .WB_o_alu_data  (alu_data_WB  ),
    .WB_o_lsu_data  (lsu_data_WB  ),
    .WB_o_wb_sel    (wb_sel_WB    ),
    .WB_o_reg_wren  (reg_wren_WB  )
  );
  WB WB (
    .i_pc       (pc_WB       ),
    .i_alu_data (alu_data_WB ),
    .i_lsu_data (lsu_data_WB ),
    .i_wb_sel   (wb_sel_WB   ),
    .o_rd_data  (rd_data_WB  )
  );

endmodule
