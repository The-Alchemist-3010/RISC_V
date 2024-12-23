module output_buffer(
  input  logic        i_clk,
  input  logic        i_rst_n, 
  input  logic [15:0] i_out_buf_addr, // pointer_addr    
  input  logic [31:0] i_out_buf_data, // rs2_data   
  input  logic        i_lsu_wren,     // sel
  input  logic [2:0]  i_control,      // func3  
  output logic [31:0] o_out_buf_data, // wb_regfile  
  output logic [31:0] o_io_ledr,     
  output logic [31:0] o_io_ledg,     
  output logic [6:0]  o_io_hex0,     
  output logic [6:0]  o_io_hex1,     
  output logic [6:0]  o_io_hex2,     
  output logic [6:0]  o_io_hex3,     
  output logic [6:0]  o_io_hex4,     
  output logic [6:0]  o_io_hex5,     
  output logic [6:0]  o_io_hex6,     
  output logic [6:0]  o_io_hex7,    
  output logic [31:0] o_io_lcd
);

  parameter BUFFER_SIZE = 64;
  logic [7:0] buffer_array [BUFFER_SIZE - 1:0];

  
  localparam [2:0] 	BYTE_ACCESS      = 3'b000,
					HALFWORD_ACCESS  = 3'b001,
					WORD_ACCESS      = 3'b010,
					UNSIGNED_BYTE    = 3'b100,
					UNSIGNED_HALF    = 3'b101;
  
  localparam [15:0] LED_RED_ADDR      = 8'h00,
                    LED_GREEN_ADDR    = 8'h10,
                    HEX0_ADDR         = 8'h20,
                    HEX1_ADDR         = 8'h21,
                    HEX2_ADDR         = 8'h22,
                    HEX3_ADDR         = 8'h23,
                    HEX4_ADDR         = 8'h24,
                    HEX5_ADDR         = 8'h25,
                    HEX6_ADDR         = 8'h26,
                    HEX7_ADDR         = 8'h27,
                    LCD_ADDR          = 8'h30,
                    MAX_ADDR          = 8'h3F;
  
  logic [7:0] aligned_addr_half, aligned_addr_word;
  
  assign aligned_addr_half = i_out_buf_addr[7:0] & 8'hFE;
  assign aligned_addr_word = i_out_buf_addr[7:0] & 8'hFC;

  logic  ouput_region;
  assign output_region = (16'h7000 <=i_out_buf_addr  && i_out_buf_addr <= 16'h703F) ? 1'b1 : 1'b0;
						  
  always_ff @(posedge i_clk) begin: proc_write_buffer
    if(~i_rst_n) begin
      buffer_array[LED_RED_ADDR]      <= 8'b0;
      buffer_array[LED_RED_ADDR + 1]  <= 8'b0;
      buffer_array[LED_RED_ADDR + 2]  <= 8'b0;
      buffer_array[LED_GREEN_ADDR]    <= 8'b0;
      buffer_array[HEX0_ADDR]         <= 8'b0; 
      buffer_array[HEX1_ADDR]         <= 8'b0;
      buffer_array[HEX2_ADDR]         <= 8'b0;
      buffer_array[HEX3_ADDR]         <= 8'b0;
      buffer_array[HEX4_ADDR]         <= 8'b0;
      buffer_array[HEX5_ADDR]         <= 8'b0;
      buffer_array[HEX6_ADDR]         <= 8'b0;
      buffer_array[HEX7_ADDR]         <= 8'b0;
    end else if (i_lsu_wren && output_region) begin
        case (i_control[1:0])
        2'b00: begin
				 buffer_array[i_out_buf_addr[7:0]]       = i_out_buf_data[7:0];
			   end
        2'b01: begin
                 buffer_array[aligned_addr_half]         = i_out_buf_data[7:0];
                 buffer_array[aligned_addr_half + 1]     = i_out_buf_data[15:8];
        	   end
        2'b10: begin
                 buffer_array[aligned_addr_half]         = i_out_buf_data[ 7: 0];
           		 buffer_array[aligned_addr_half + 1]     = i_out_buf_data[15: 8];
                 buffer_array[aligned_addr_half + 2]     = i_out_buf_data[23:16];
                 buffer_array[aligned_addr_half + 3]     = i_out_buf_data[31:24];
               end
      endcase
    end
  end
  
   always_comb begin: output_select
    case (i_control)
      BYTE_ACCESS: begin
        			 if (output_region) begin
						o_out_buf_data = {{24{buffer_array[i_out_buf_addr[7:0]][7]}}, buffer_array[i_out_buf_addr[7:0]]};
					 end else begin 
						o_out_buf_data = 32'hz;
      				 end
	               end
      HALFWORD_ACCESS: begin
						if(output_region) begin
							o_out_buf_data = {{16{buffer_array[aligned_addr_half + 1][7]}}, buffer_array[aligned_addr_half + 1],buffer_array[aligned_addr_half]};
					    end else begin
							o_out_buf_data = 32'hz;
					    end
                       end
      WORD_ACCESS:     begin
						if(output_region) begin
							o_out_buf_data = {buffer_array[aligned_addr_half + 3],buffer_array[aligned_addr_half + 2],buffer_array[aligned_addr_half + 1],buffer_array[aligned_addr_half]};
					    end else begin
							o_out_buf_data = 32'hz;
					    end
                       end
      UNSIGNED_BYTE: begin
        			 if (output_region) begin
						o_out_buf_data = {24'b0, buffer_array[i_out_buf_addr[7:0]]};
					 end else begin 
						o_out_buf_data = 32'hz;
      				 end
	               end
      UNSIGNED_HALF: begin
						if(output_region) begin
							o_out_buf_data = {16'b0,buffer_array[aligned_addr_half + 1],buffer_array[aligned_addr_half]};
					    end else begin
							o_out_buf_data = 32'hz;
					    end
                       end
      default: o_out_buf_data = 32'hz;
    endcase
  end
	

  assign o_io_ledr = {buffer_array[LED_RED_ADDR + 3], buffer_array[LED_RED_ADDR + 2], buffer_array[LED_RED_ADDR + 1], buffer_array[LED_RED_ADDR]};
  assign o_io_ledg = {buffer_array[LED_GREEN_ADDR + 3], buffer_array[LED_GREEN_ADDR + 2], buffer_array[LED_GREEN_ADDR + 1], buffer_array[LED_GREEN_ADDR]};
  assign o_io_hex0 = buffer_array[HEX0_ADDR][6:0];
  assign o_io_hex1 = buffer_array[HEX1_ADDR][6:0];
  assign o_io_hex2 = buffer_array[HEX2_ADDR][6:0];
  assign o_io_hex3 = buffer_array[HEX3_ADDR][6:0];
  assign o_io_hex4 = buffer_array[HEX4_ADDR][6:0];
  assign o_io_hex5 = buffer_array[HEX5_ADDR][6:0];
  assign o_io_hex6 = buffer_array[HEX6_ADDR][6:0];
  assign o_io_hex7 = buffer_array[HEX7_ADDR][6:0];
  assign o_io_lcd  = {buffer_array[LCD_ADDR + 3], buffer_array[LCD_ADDR + 2], buffer_array[LCD_ADDR + 1], buffer_array[LCD_ADDR]};
  
endmodule


