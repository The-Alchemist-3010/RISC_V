module IF_INST_MEM(
    input  logic [31:0] i_pc_if,
    output logic [31:0] o_inst_if
);
    logic [7:0][3:0] imem [2**11-1:0];  

    initial begin
        $readmemh("../02_test/dump/mem2.dump", imem);
    end

    assign o_inst_if = imem[i_pc_if[12:2]];
endmodule

