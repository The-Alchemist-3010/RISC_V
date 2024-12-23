module EX ( 
  input logic [31:0] i_pc        ,
  input logic [ 3:0] i_alu_sel   ,
  input logic [31:0] i_imm       ,
  input logic        i_brun      ,
  input logic        i_a_sel     , 
  input logic        i_b_sel     ,    
  input logic [31:0] i_rs1_data  , 
  input logic [31:0] i_rs2_data  ,
  input logic [31:0] i_data_alu_mux,
  input logic [31:0] i_data_wb_mux,
  input logic [ 1:0]  opa_sel     ,
  input logic [ 1:0]  opb_sel     ,
 
  output  logic        o_brlt      ,
  output  logic        o_breq      ,
  output  logic [31:0] o_alu_data  ,
  output  logic [31:0] o_rs2_data_mux 

);
  logic [31:0] data_a_ex, data_b_ex;

  logic [31:0] i_rs1_data_mux  ;
  logic [31:0] i_rs2_data_mux  ;

  always_comb begin
    case(opa_sel)	
    2'b00:
		i_rs1_data_mux =  i_rs1_data;
    2'b01:
        i_rs1_data_mux = i_data_wb_mux;
    2'b10:
        i_rs1_data_mux = i_data_alu_mux;
    default:
        i_rs1_data_mux = 32'b0;
   endcase
  end
  
  always_comb begin
    case(opb_sel)	
    2'b00:
		i_rs2_data_mux =  i_rs2_data;
    2'b01:
        i_rs2_data_mux = i_data_wb_mux;
    2'b10:
        i_rs2_data_mux = i_data_alu_mux;
    default:
        i_rs2_data_mux = 32'b0;
	endcase
  end


  assign data_a_ex = i_a_sel ? i_pc : i_rs1_data_mux;
  assign data_b_ex = i_b_sel ? i_imm : i_rs2_data_mux;

  assign o_rs2_data_mux = i_rs2_data_mux;

  EX_ALU EX_ALU (
    .i_operand_a_ex (data_a_ex ),
    .i_operand_b_ex (data_b_ex ),
    .i_alu_op_ex    (i_alu_sel ),
    .o_alu_data_ex  (o_alu_data)
  );

  EX_BRC EX_BRC (
    .i_rs1_data_id (data_a_ex ),
    .i_rs2_data_id (data_b_ex ),
    .i_br_un_id    (i_brun     ),
    .o_br_less_id  (o_brlt     ),
    .o_br_equal_id (o_breq     )
  );
endmodule
