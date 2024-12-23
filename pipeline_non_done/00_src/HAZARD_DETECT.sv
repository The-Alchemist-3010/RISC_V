module HAZARD_DETECT (
  input       [31:0] EX_inst          , 
  input       [31:0] ID_inst          ,
  input       [31:0] MEM_inst         ,
  input              EX_brlt          , 
  input              EX_breq          ,
  input              EX_reg_wren      ,
  input              MEM_reg_wren     ,
  input              ID_rs1_hazard_on ,
  input              ID_rs2_hazard_on ,
  output reg         o_flush          ,
  output reg         o_stall
);

  wire [4:0] ID_rs1, ID_rs2, EX_rd, MEM_rd;
  wire [4:0] EX_opcode;
  wire [2:0] EX_funct_3;
  wire       hazard_on;

  assign EX_opcode = EX_inst[6:2]  ;                             
  assign ID_rs1    = ID_inst[19:15];
  assign ID_rs2    = ID_inst[24:20];
  assign EX_rd     = EX_inst[11: 7];
  assign MEM_rd    = MEM_inst[11:7];
  assign EX_funct_3 = EX_inst[14:12];

  always_comb begin : proc_flush_control
    case(EX_opcode) 
      5'b11000: begin
        case(EX_funct_3) 
          3'b000: begin
            o_flush = EX_breq ;
          end
          3'b001: begin
            o_flush = !EX_breq;
          end
          3'b100, 3'b110: begin
            o_flush = EX_brlt ;
          end
          3'b101, 3'b111: begin
            o_flush = !EX_brlt;
          end
          default: 
            o_flush = 1'b0;
        endcase 
      end 
	  5'b11011, 5'b11001: begin
      	o_flush = 1'b1;
	  end 
    default: 
      o_flush = 1'b0;
    endcase
  end
  
  assign hazard_on = ((ID_rs1_hazard_on & (((EX_rd != 5'b00000) & ((EX_rd == ID_rs1) & EX_reg_wren)) | ((MEM_rd != 5'b00000) & ((MEM_rd == ID_rs1) & MEM_reg_wren))))) |
                     ((ID_rs2_hazard_on & (((EX_rd != 5'b00000) & ((EX_rd == ID_rs2) & EX_reg_wren)) | ((MEM_rd != 5'b00000) & ((MEM_rd == ID_rs2) & MEM_reg_wren)))));

  always_comb begin : proc_stall_control
    case(hazard_on) 
      1'b1:    o_stall = 1'b1;
      default: o_stall = 1'b0;
    endcase
  end

endmodule
