module REG_IF_ID (
  input             i_clk    , 
  input             i_reset_n, 
  input             i_flush  ,
  input             i_stall  ,
  input      [31:0] IF_i_inst, 
  input      [31:0] IF_i_pc  ,
  output reg [31:0] ID_o_inst, 
  output reg [31:0] ID_o_pc
);

  always_ff @(posedge i_clk or negedge i_reset_n) begin
    if(~i_reset_n) begin
      ID_o_pc   <= 32'd0;
      ID_o_inst <= 32'd0;
    end else if(i_flush) begin
      ID_o_pc   <= 32'd0;
      ID_o_inst <= 32'd0; 
	end else if(i_stall) begin
	  ID_o_pc   <= ID_o_pc;
      ID_o_pc   <= ID_o_pc;
    end else begin
      ID_o_pc   <= IF_i_pc;
      ID_o_inst <= IF_i_inst;
    end
  end

endmodule
