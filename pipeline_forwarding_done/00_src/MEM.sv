module MEM (
  input                i_clk         ,
  input                i_reset_n     ,

  input        [31:0]  i_addr        ,
  input        [31:0]  i_rs2_data    ,
  input                i_mem_wren    ,
  input        [ 2:0]  i_mem_funct_3 ,
  output       [31:0]  o_lsu_data    ,
  output logic [31:0]  o_io_ledr     ,     
  output logic [31:0]  o_io_ledg     ,     
  output logic [ 6:0]  o_io_hex0     ,     
  output logic [ 6:0]  o_io_hex1     ,     
  output logic [ 6:0]  o_io_hex2     ,     
  output logic [ 6:0]  o_io_hex3     ,     
  output logic [ 6:0]  o_io_hex4     ,     
  output logic [ 6:0]  o_io_hex5     ,     
  output logic [ 6:0]  o_io_hex6     ,     
  output logic [ 6:0]  o_io_hex7     ,    
  output logic [31:0]  o_io_lcd      ,      
  input  logic [31:0]  i_io_sw       ,    
  input  logic [ 3:0]  i_io_btn 
);

  MEM_LSU MEM_LSU (
    .i_clk      (i_clk         ),
    .i_rst_n    (i_reset_n     ),
    .i_lsu_addr (i_addr        ),   
    .i_st_data  (i_rs2_data    ),    
    .i_lsu_wren (i_mem_wren    ),
    .i_control  (i_mem_funct_3 ),  
    .o_ld_data  (o_lsu_data    ),    
    .o_io_ledr  (o_io_ledr     ),     
    .o_io_ledg  (o_io_ledg     ),     
    .o_io_hex0  (o_io_hex0     ),     
    .o_io_hex1  (o_io_hex1     ),     
    .o_io_hex2  (o_io_hex2     ),     
    .o_io_hex3  (o_io_hex3     ),     
    .o_io_hex4  (o_io_hex4     ),     
    .o_io_hex5  (o_io_hex5     ),     
    .o_io_hex6  (o_io_hex6     ),     
    .o_io_hex7  (o_io_hex7     ),    
    .o_io_lcd   (o_io_lcd      ),      
    .i_io_sw    (i_io_sw       ),    
    .i_io_btn   (i_io_btn      ) 
  );
endmodule
