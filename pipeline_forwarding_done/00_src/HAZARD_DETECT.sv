module HAZARD_DETECT (
  input       [31:0] EX_inst          , 
  input       [31:0] MEM_inst         ,
  input       [31:0] WB_inst          ,
  input              EX_brlt          , 
  input              EX_breq          ,
  input              EX_reg_wren      ,
  input              MEM_reg_wren     ,
  input              WB_reg_wren      ,
  input              EX_rs1_hazard_on ,
  input              EX_rs2_hazard_on ,
  output reg         o_flush_ex_mem   ,
  output reg         o_flush_if_id    ,
  output reg         o_flush_id_ex    ,
  output reg         o_flush_mux_pc   ,
  output reg         o_stall_pc       ,
  output reg         o_stall_if_id    ,
  output reg         o_stall_id_ex    ,
  output reg [1:0]   opa_sel          ,
  output reg [1:0]   opb_sel          

);

  wire [4:0] ID_rs1, ID_rs2, EX_rd, EX_rs1, EX_rs2, MEM_rd, WB_rd;
  wire [4:0] EX_opcode, MEM_opcode;
  wire [2:0] EX_funct_3;
 

  assign EX_opcode  = EX_inst  [ 6: 2]; 
  assign MEM_opcode = MEM_inst [ 6: 2];                            
  assign EX_rs1     = EX_inst  [19:15];
  assign EX_rs2     = EX_inst  [24:20];
  assign EX_rd      = EX_inst  [11: 7];
  assign MEM_rd     = MEM_inst [11: 7];
  assign WB_rd      = WB_inst  [11: 7];
  assign EX_funct_3 = EX_inst  [14:12];
  
  /* processing branch */
  always_comb begin : proc_flush_control
    case(EX_opcode) 
      5'b11000: begin
        case(EX_funct_3) 
          3'b000: begin
            o_flush_if_id  = EX_breq ;
			      o_flush_id_ex  = EX_breq ;
			      o_flush_mux_pc = EX_breq ;
          end
          3'b001: begin
            o_flush_if_id  = !EX_breq;
			      o_flush_id_ex  = !EX_breq;
			      o_flush_mux_pc = !EX_breq;
          end
          3'b100, 3'b110: begin
            o_flush_if_id  = EX_brlt ;
			      o_flush_id_ex  = EX_brlt ;
			      o_flush_mux_pc = EX_brlt ;
          end
          3'b101, 3'b111: begin
            o_flush_if_id  = !EX_brlt;
			      o_flush_id_ex  = !EX_brlt;
			      o_flush_mux_pc = !EX_brlt;
          end
          default: begin
            o_flush_if_id  = 1'b0;
			      o_flush_id_ex  = 1'b0;
			      o_flush_mux_pc = 1'b0;
          end
        endcase 
      end 
	  5'b11011, 5'b11001: begin
      	o_flush_if_id  = 1'b1;
		    o_flush_id_ex  = 1'b1;
		    o_flush_mux_pc = 1'b1;
	  end 
    default: begin
      o_flush_if_id  = 1'b0;
	    o_flush_id_ex  = 1'b0;
	    o_flush_mux_pc = 1'b0;
    end
    endcase
  end

  /*processing case 1 */
  
  always_comb begin
        //Forward operand_a
        if ((MEM_reg_wren == 1) && (MEM_rd != 0) && (MEM_rd == EX_rs1)) 
            opa_sel = 2'b10;
        else if ((WB_reg_wren == 1) && (WB_rd != 0) && (WB_rd == EX_rs1)) 
            opa_sel = 2'b01;
        else 
            opa_sel = 2'b00;
        //Forward operand_b
        if ((MEM_reg_wren == 1) && (MEM_rd != 0) && (MEM_rd == EX_rs2)) 
            opb_sel = 2'b10;
        else if ((WB_reg_wren == 1) && (WB_rd != 0) && (WB_rd == EX_rs2)) 
            opb_sel = 2'b01;
        else 
            opb_sel = 2'b00;
  end
  /*processing case 2 */
  always_comb begin
	if((MEM_opcode == 5'b00000) && (MEM_rd != 0) && (((MEM_rd == EX_rs1) || EX_rs1_hazard_on) && (EX_rs2_hazard_on || (MEM_rd == EX_rs2))))	 begin
		o_stall_pc     = 1'b1;
    o_stall_if_id  = 1'b1;
 		o_stall_id_ex  = 1'b1;
		o_flush_ex_mem = 1'b1;
	end else begin
		o_stall_pc     = 1'b0;
    o_stall_if_id  = 1'b0;
 		o_stall_id_ex  = 1'b0;
		o_flush_ex_mem = 1'b0;
	end
  end  

endmodule
