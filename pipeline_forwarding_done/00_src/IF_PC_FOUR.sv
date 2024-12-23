module IF_PC_FOUR(
    input  logic [31:0]   i_pc_if      ,
    output logic [31:0]   o_pc_four_if
);

assign o_pc_four_if = i_pc_if + 4;

endmodule