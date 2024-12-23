module ID_REGFILE (                                              
    input logic  [31:0] i_rd_data_id ,
    input logic  [ 4:0] i_rd_addr_id ,
    input logic         i_rd_wren_id ,
    input logic         i_clk        ,
    input logic         i_reset_n    ,
    input logic  [ 4:0] i_rs1_addr_id,
    input logic  [ 4:0] i_rs2_addr_id,
    output logic [31:0] o_rs1_data_id,
    output logic [31:0] o_rs2_data_id
);


    reg [31:0] registerfile [31:0];

    always @(negedge i_clk or negedge i_reset_n ) begin
        if (~i_reset_n) begin
            for (int i = 0; i < 32; i++) begin
                registerfile[i]     <= 32'b0   ;
            end                       
        end else if(i_rd_wren_id && (i_rd_addr_id != 32'b0)) begin
            registerfile[i_rd_addr_id] <= i_rd_data_id;
        end
    end
    
    assign    o_rs1_data_id = registerfile[i_rs1_addr_id];
    assign    o_rs2_data_id = registerfile[i_rs2_addr_id];
     
endmodule

