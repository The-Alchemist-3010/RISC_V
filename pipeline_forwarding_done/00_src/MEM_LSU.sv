module MEM_LSU(
  input  logic        i_clk     ,
  input  logic        i_rst_n   ,
  input  logic [31:0] i_lsu_addr,   
  input  logic [31:0] i_st_data ,    
  input  logic        i_lsu_wren,
  input  logic [ 2:0] i_control ,  
  output logic [31:0] o_ld_data ,    
  output logic [31:0] o_io_ledr ,     
  output logic [31:0] o_io_ledg ,     
  output logic [ 6:0] o_io_hex0 ,     
  output logic [ 6:0] o_io_hex1 ,     
  output logic [ 6:0] o_io_hex2 ,     
  output logic [ 6:0] o_io_hex3 ,     
  output logic [ 6:0] o_io_hex4 ,     
  output logic [ 6:0] o_io_hex5 ,     
  output logic [ 6:0] o_io_hex6 ,     
  output logic [ 6:0] o_io_hex7 ,    
  output logic [31:0] o_io_lcd  ,      
  input  logic [31:0] i_io_sw   ,    
  input  logic [3:0]  i_io_btn 
);

  logic [31:0] in_buf_data, out_buft_data, o_dmem_data ;
  always_comb begin: proc_mux_ld_data
    if(16'h7800 <= i_lsu_addr[15:0] && i_lsu_addr[15:0] <= 16'h781F) o_ld_data = in_buf_data;
	 else if (16'h7000 <=i_lsu_addr[15:0]  && i_lsu_addr[15:0] <= 16'h703F) o_ld_data = out_buft_data;
	 else if ((i_lsu_addr[15:12] == 4'h2) || (i_lsu_addr[15:12] == 4'h3)) o_ld_data = o_dmem_data;
	 else o_ld_data = 32'hz;
  end
  
  input_buffer i_buf_mem(
  .i_control     (i_control        ),
  .i_in_buf_addr (i_lsu_addr[15:0] ),
  .i_io_sw       (i_io_sw          ), 
  .i_io_btn      (i_io_btn         ),
  .o_in_buf_data (in_buf_data      )
  );

  output_buffer o_buf_mem(
  .i_clk          (i_clk            ),
  .i_rst_n        (i_rst_n          ), 
  .i_out_buf_addr (i_lsu_addr[15:0] ),    
  .i_out_buf_data (i_st_data        ),    
  .i_lsu_wren     (i_lsu_wren       ),
  .i_control      (i_control        ),  
  .o_out_buf_data (out_buft_data    ),    
  .o_io_ledr      (o_io_ledr        ),     
  .o_io_ledg      (o_io_ledg        ),     
  .o_io_hex0      (o_io_hex0        ),     
  .o_io_hex1      (o_io_hex1        ),     
  .o_io_hex2      (o_io_hex2        ),     
  .o_io_hex3      (o_io_hex3        ),     
  .o_io_hex4      (o_io_hex4        ),     
  .o_io_hex5      (o_io_hex5        ),     
  .o_io_hex6      (o_io_hex6        ),     
  .o_io_hex7      (o_io_hex7        ),    
  .o_io_lcd       (o_io_lcd         )
);

  data_mem dmem(
  .i_clk       (i_clk            ),
  .i_rst_n     (i_rst_n          ),
  .i_lsu_addr  (i_lsu_addr[15:0] ),
  .i_st_data   (i_st_data        ),
  .i_lsu_wren  (i_lsu_wren       ),
  .i_control   (i_control        ),
  .o_dmem_data (o_dmem_data      )
  );
endmodule 

module output_buffer(
  input  logic        i_clk          ,
  input  logic        i_rst_n        , 
  input  logic [15:0] i_out_buf_addr ,    
  input  logic [31:0] i_out_buf_data ,
  input  logic        i_lsu_wren     ,     
  input  logic [ 2:0] i_control      ,      
  output logic [31:0] o_out_buf_data ,  
  output logic [31:0] o_io_ledr      ,     
  output logic [31:0] o_io_ledg      ,     
  output logic [ 6:0] o_io_hex0      ,     
  output logic [ 6:0] o_io_hex1      ,     
  output logic [ 6:0] o_io_hex2      ,     
  output logic [ 6:0] o_io_hex3      ,     
  output logic [ 6:0] o_io_hex4      ,     
  output logic [ 6:0] o_io_hex5      ,     
  output logic [ 6:0] o_io_hex6      ,     
  output logic [ 6:0] o_io_hex7      ,    
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
  //localparam MEM_SIZE = 100;
  
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


