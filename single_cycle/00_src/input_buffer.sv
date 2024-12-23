module input_buffer(
  input  logic [2:0]  i_control, //func3
  input  logic [15:0] i_in_buf_addr,
  input  logic [31:0] i_io_sw, 
  input  logic [3:0]  i_io_btn,
  output logic [31:0] o_in_buf_data
);
  // Buffer size
  parameter BUFFER_CAPACITY = 32;
  logic [7:0] buffer_mem [BUFFER_CAPACITY - 1:0];
  
  // Address definitions
  localparam [7:0] SWITCH_ADDR = 8'h00,
                   BUTTON_ADDR = 8'h10,
                   MAX_ADDR    = 8'h1F;

  // Operation codes (func3)
  localparam [2:0] BYTE_LOAD         = 3'b000,
                   HALFWORD_LOAD     = 3'b001,
                   WORD_LOAD         = 3'b010,
                   BYTE_LOAD_UNSIGNED = 3'b100,
                   HALFWORD_LOAD_UNSIGNED = 3'b101;

  logic [7:0] aligned_addr_half, aligned_addr_word;

  assign aligned_addr_half = i_in_buf_addr & 8'hFE;
  assign aligned_addr_word = i_in_buf_addr & 8'hFC;

  logic input_region ;
  
  assign input_region = (16'h7800 <= i_in_buf_addr &&  i_in_buf_addr <= 16'h781F ) ? 1'b1 : 1'b0;	  
  
  assign buffer_mem[SWITCH_ADDR]     = i_io_sw[7:0];
  assign buffer_mem[SWITCH_ADDR + 1] = i_io_sw[15:8];
  assign buffer_mem[SWITCH_ADDR + 2] = i_io_sw[23:16];
  assign buffer_mem[SWITCH_ADDR + 3] = i_io_sw[31:24];
  assign buffer_mem[BUTTON_ADDR]     = {4'h0, i_io_btn};
  
  always_comb begin: output_memory_values
    case (i_control)
      BYTE_LOAD: begin
        			 if (input_region) begin
						o_in_buf_data = {{24{buffer_mem[i_in_buf_addr[7:0]][7]}}, buffer_mem[i_in_buf_addr[7:0]]};
					 end else begin 
						o_in_buf_data = 32'hz;
      				 end
	               end
      HALFWORD_LOAD: begin
						if(input_region) begin
							o_in_buf_data = {{16{buffer_mem[aligned_addr_half + 1][7]}},buffer_mem[aligned_addr_half + 1],buffer_mem[aligned_addr_half]};
					    end else begin
							o_in_buf_data = 32'hz;
					    end
                       end
      WORD_LOAD:     begin
						if(input_region) begin
							o_in_buf_data = {buffer_mem[aligned_addr_half + 3],buffer_mem[aligned_addr_half + 2],buffer_mem[aligned_addr_half + 1],buffer_mem[aligned_addr_half]};
					    end else begin
							o_in_buf_data = 32'hz;
					    end
                       end
      BYTE_LOAD_UNSIGNED: begin
        			 if (input_region) begin
						o_in_buf_data = {24'b0, buffer_mem[i_in_buf_addr[7:0]]};
					 end else begin 
						o_in_buf_data = 32'hz;
      				 end
	               end
      HALFWORD_LOAD_UNSIGNED: begin
						if(input_region) begin
							o_in_buf_data = {16'b0,buffer_mem[aligned_addr_half + 1],buffer_mem[aligned_addr_half]};
					    end else begin
							o_in_buf_data = 32'hz;
					    end
                       end
      default: o_in_buf_data = 32'hz;
    endcase
  end

endmodule

