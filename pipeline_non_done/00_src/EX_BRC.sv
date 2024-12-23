module EX_BRC(
    input   [31:0]  i_rs1_data_id,
    input   [31:0]  i_rs2_data_id,
    input           i_br_un_id   ,
    output          o_br_less_id ,
    output          o_br_equal_id
);

addsub_1 addsubcomp (
    .inA         (i_rs1_data_id),
    .inB         (i_rs2_data_id),
    .neg_sel     (1'b1         ),
    .unsigned_sel(i_br_un_id   ),
    .result      (),
    .less_than   (o_br_less_id),
    .equal       (o_br_equal_id)
  );

endmodule

module addsub_1 (
  input  [31:0] inA         ,
  input  [31:0] inB         ,
  input         neg_sel     ,
  input         unsigned_sel,
  output [31:0] result      ,
  output        less_than   ,
  output        equal
);

  wire [32:0] extendedA, extendedB;
  assign extendedA = unsigned_sel ? {1'b0, inA} : {1'(inA[31]), inA};
  assign extendedB = unsigned_sel ? {1'b0, inB} : {1'(inB[31]), inB};

  wire [32:0] newB;
  assign newB = neg_sel ? (~extendedB + 1'b1) : extendedB;

  assign {less_than, result} = extendedA + newB;

  assign equal = (result == 32'd0);
endmodule
