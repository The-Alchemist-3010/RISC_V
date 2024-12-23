module data_mem(
  input  logic        i_clk,
  input  logic        i_rst_n,
  input  logic [15:0] i_lsu_addr,    
  input  logic [31:0] i_st_data,    
  input  logic        i_lsu_wren, 
  input  logic [2:0]  i_control,  
  output logic [31:0] o_dmem_data 
);
  localparam [2:0] 	BYTE_ACCESS      = 3'b000,
					HALFWORD_ACCESS  = 3'b001,
					WORD_ACCESS      = 3'b010,
					UNSIGNED_BYTE    = 3'b100,
					UNSIGNED_HALF    = 3'b101;

  localparam [12:0] MAX_ADDR = 13'b1_1111_1111_1111;
	
  localparam MEM_SIZE = 8192;

  logic [7:0] mem_array [MEM_SIZE - 1:0];

  //Twos varibles supporting misaligned
  logic [13:0] aligned_addr_half, aligned_addr_word;

  //assign value from real addressing
  assign aligned_addr_half = i_lsu_addr[12:0] & 13'b1_1111_1111_1110; 
  assign aligned_addr_word = i_lsu_addr[12:0] & 13'b1_1111_1111_1100;

  //The variable define which address in data region
  logic mem_region_sel;
  assign mem_region_sel = (i_lsu_addr[15:12] == 4'h2) | (i_lsu_addr[15:12] == 4'h3);
	
  longint idx;
	
  always_ff @(posedge i_clk) begin
    if (~i_rst_n) begin
      for (idx = 0; idx < MEM_SIZE; idx++) begin
        mem_array[idx] <= 8'b0;
      end
    end else if (i_lsu_wren && mem_region_sel) begin
      case (i_control[1:0])
        2'b00: begin
				 mem_array[i_lsu_addr[12:0]]          = i_st_data[7:0];
			   end
        2'b01: begin
                 mem_array[aligned_addr_half]         = i_st_data[7:0];
                 mem_array[aligned_addr_half + 1]     = i_st_data[15:8];
        	   end
        2'b10: begin
                 mem_array[aligned_addr_half]         = i_st_data[ 7: 0];
           		 mem_array[aligned_addr_half + 1]     = i_st_data[15: 8];
                 mem_array[aligned_addr_half + 2]     = i_st_data[23:16];
                 mem_array[aligned_addr_half + 3]     = i_st_data[31:24];
               end
      endcase
    end
  end
	 
  always_comb begin: output_memory_values
    case (i_control)
      BYTE_ACCESS: begin
        			 if (mem_region_sel) begin
						o_dmem_data = {{24{mem_array[i_lsu_addr[12:0]][7]}}, mem_array[i_lsu_addr[12:0]]};
					 end else begin 
						o_dmem_data = 32'h0;
      				 end
	               end
      HALFWORD_ACCESS: begin
						if(mem_region_sel) begin
							o_dmem_data = {{16{mem_array[aligned_addr_half + 1][7]}},mem_array[aligned_addr_half + 1],mem_array[aligned_addr_half]};
					    end else begin
							o_dmem_data = 32'h0;
					    end
                       end
      WORD_ACCESS:     begin
						if(mem_region_sel) begin
							o_dmem_data = {mem_array[aligned_addr_half + 3],mem_array[aligned_addr_half + 2],mem_array[aligned_addr_half + 1],mem_array[aligned_addr_half]};
					    end else begin
							o_dmem_data = 32'h0;
					    end
                       end
      UNSIGNED_BYTE: begin
        			 if (mem_region_sel) begin
						o_dmem_data = {24'b0, mem_array[i_lsu_addr[12:0]]};
					 end else begin 
						o_dmem_data = 32'h0;
      				 end
	               end
      UNSIGNED_HALF: begin
						if(mem_region_sel) begin
							o_dmem_data = {16'b0,mem_array[aligned_addr_half + 1],mem_array[aligned_addr_half]};
					    end else begin
							o_dmem_data = 32'h0;
					    end
                       end
      default: o_dmem_data = 32'hz;
    endcase
  end
	
endmodule


