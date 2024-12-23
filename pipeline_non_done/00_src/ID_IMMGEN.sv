module ID_IMMGEN (
  input      [31:7] i_instr_id  ,
  input      [ 4:0] i_imm_sel_id,
  output reg [31:0] o_immgen_id
);

  logic [31:11] signxt;

  always_comb begin
    if (i_instr_id[31])
      signxt = {21{1'b1}};
    else
      signxt = 0;
    if(i_imm_sel_id[0])                                                    
      o_immgen_id = {signxt[31:11],i_instr_id[30:20]};
    else if (i_imm_sel_id[1])                                              
      o_immgen_id = {signxt[31:11],i_instr_id[30:25],i_instr_id[11:7]};
    else if (i_imm_sel_id[2])                                              
      o_immgen_id = {signxt[31:12],i_instr_id[7],i_instr_id[30:25],i_instr_id[11:8],1'b0};
    else if (i_imm_sel_id[3])                                             
      o_immgen_id = {i_instr_id[31:12],12'h0};
    else if (i_imm_sel_id[4])                                              
      o_immgen_id = {signxt[31:20],i_instr_id[19:12],i_instr_id[20],i_instr_id[30:21],1'b0};
    else
      o_immgen_id = 32'd0;
  end
endmodule