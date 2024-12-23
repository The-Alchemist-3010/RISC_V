module ID_CONTROLLER (
  input  logic [31:0] i_inst_id          ,
  output logic [ 4:0] o_imm_sel_id       ,
  output logic [ 3:0] o_alu_sel_id       ,
  output logic        o_reg_wren_id      , 
  output logic        o_brun_id          , 
  output logic        o_b_sel_id         , 
  output logic        o_a_sel_id         , 
  output logic        o_mem_wren_id      ,
  output logic [ 1:0] o_wb_sel_id        ,
  output logic [ 2:0] o_funct3_id        ,
  output logic        o_rs1_hazard_on_id ,
  output logic        o_rs2_hazard_on_id 
);

  wire [4:0] opcode   = i_inst_id[6:2]  ;
  wire [2:0] funct3   = i_inst_id[14:12];
  wire [6:0] funct7   = i_inst_id[31:25];
  wire [6:0] opcode_1 = i_inst_id[6:0];

  wire Rtype, Itype, Stype, Btype, Jtype, JItype, Utype, Ltype; 

  assign Rtype  = (opcode == 5'b01100);
  assign Itype  = ({opcode[4:3], opcode[1:0]} == 4'b0000);
  assign Stype  = (opcode == 5'b01000);
  assign Btype  = (opcode == 5'b11000);
  assign Utype  = ({opcode[4], opcode[2:0]} == 4'b0101);     
  assign Jtype  = (opcode == 5'b11011);                      
  assign JItype = (opcode == 5'b11001);                      
  assign Ltype  = ~(|opcode);                               

  assign o_imm_sel_id   = {Jtype, Utype, Btype, Stype, Itype | JItype};
  assign o_brun_id      = funct3[1];
  assign o_a_sel_id     = Btype | Jtype | Utype;
  assign o_b_sel_id     = ~Rtype;
  assign o_mem_wren_id  = Stype;
  assign o_reg_wren_id  = ~Btype & ~Stype;
  assign o_wb_sel_id    = Ltype ? 2'b00 : (Jtype | JItype) ? 2'b10 : 2'b01;
  assign o_funct3_id    = funct3;

 
	always_comb begin
		case(opcode_1)
			7'b0110011: begin
				case(funct3)
					3'b000: begin
						case(funct7)
							7'b0000000: o_alu_sel_id = 4'b0000;
							7'b0100000: o_alu_sel_id = 4'b0001;
						endcase
					end
					3'b001: o_alu_sel_id = 4'b0111; 
					3'b010: o_alu_sel_id = 4'b0010; 
					3'b011: o_alu_sel_id = 4'b0011; 
					3'b100: o_alu_sel_id = 4'b0100; 
					3'b101: begin
						case(funct7)
							7'b0000000:  o_alu_sel_id = 4'b1000; 
							7'b0100000:  o_alu_sel_id = 4'b1001; 
						endcase
					end
					3'b110: o_alu_sel_id = 4'b0101; 
					3'b111: o_alu_sel_id = 4'b0110; 
				endcase
			end
			7'b0010011: begin
				case(funct3)
					3'b000:  o_alu_sel_id = 4'b0000; 
					3'b010:  o_alu_sel_id = 4'b0010; 
					3'b011:  o_alu_sel_id = 4'b0011; 
					3'b100:  o_alu_sel_id = 4'b0100; 
					3'b110:  o_alu_sel_id = 4'b0101; 
					3'b111:  o_alu_sel_id = 4'b0110; 
					3'b001:  o_alu_sel_id = 4'b0111; 
					3'b101: begin
						case(funct7)
							7'b0000000:  o_alu_sel_id = 4'b1000; 
							7'b0100000:  o_alu_sel_id = 4'b1001; 
						endcase
					end
				endcase	
			end
			7'b0100011: begin
				o_alu_sel_id   = 4'b0000;
			end
			7'b0000011: begin
				o_alu_sel_id   = 4'b0000;
			end
			7'b1100011: begin
				o_alu_sel_id   = 4'b0000;
			end
			7'b0110111: begin
				o_alu_sel_id   = 4'b1010; 
			end
			7'b0010111: begin
				o_alu_sel_id   = 4'b0000;
			end
			7'b1101111: begin
				o_alu_sel_id   = 4'b0000;
			end
			7'b1100111: begin
				o_alu_sel_id   = 4'b0000;
			end
		endcase	
	end

  always_comb begin : proc_hazard_detect
    case(opcode)
      5'b01100, 5'b01000, 5'b11000: begin
        o_rs1_hazard_on_id = 1'b1;
        o_rs2_hazard_on_id = 1'b1;
      end
      5'b00100, 5'b00000, 5'b11001: begin
        o_rs1_hazard_on_id = 1'b1;
        o_rs2_hazard_on_id = 1'b0;
      end
      default: begin 
        o_rs1_hazard_on_id = 1'b0;
        o_rs2_hazard_on_id = 1'b0;
      end
    endcase
  end


endmodule
