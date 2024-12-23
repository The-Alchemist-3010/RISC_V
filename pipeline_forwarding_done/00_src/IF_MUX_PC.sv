module IF_MUX_PC(
    input logic  [31:0]       i_alu_data_if ,
    input logic  [31:0]       i_pc_four_if  ,
    input logic               i_flush       ,
    output logic [31:0]       o_pc_next_if
);

assign o_pc_next_if = i_flush ? i_alu_data_if : i_pc_four_if;

endmodule 