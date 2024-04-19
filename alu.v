//alu
module alu(
  input signed[15:0]A,
  input signed[15:0]B,
  input Cin,
  input [3:0]Sel
  output signed[15:0]result;
);
  wire ovf,cout;
  wire [15:0]remainder;
  always@(*)begin
    case(sel)
      4'b0000:Adder16Bit(A,B,Cin,cout,result,ovf);
      4'b0001:Mult16Bit(A,B,result);
      4'b0010:division(A,B,result,remainder);
      4'b0011:nandop(A,B,result);
      4'b0100:norop(A,B,result);
      4'b0101:notop(A,result);
      4'b0110:xorop(A,B,result);
  end
endmodule
//koggestone
module PreProcessingGP (
    input  x,
    input  y,
    output G,
  	output P
);

    assign G = (x & y);
    assign P = (x ^ y);

endmodule

module GrayCell #(parameter W = 8) (
    input  [0 : (W - 1)] Gikp1,
    input  [0 : (W - 1)] Pikp1,
    input  [0 : (W - 1)] Gkj,
    output [0 : (W - 1)] Gij
);

    assign Gij = (Gikp1 | (Pikp1 & Gkj));

endmodule

module BlackCell #(parameter W = 8) (
    input  [0 : (W - 1)] Gikp1,
    input  [0 : (W - 1)] Pikp1,
    input  [0 : (W - 1)] Gkj,
    input  [0 : (W - 1)] Pkj,
    output [0 : (W - 1)] Gij,
    output [0 : (W - 1)] Pij
);

    assign Gij = (Gikp1 | (Pikp1 & Gkj));
    assign Pij = (Pikp1 & Pkj);

endmodule

module Adder16Bit (
    input  signed [15:0] A,
    input  signed [15:0] B,
    input                Cin,
    output               Cout,
    output signed [15:0] S,
  	output               overflowFlag
);
  
  	wire Cout_i;
  	wire [0:15] S_i;
  	wire [0:15] G [0:4], P [0:4];
  	genvar i;
  
    // preprocessing layer
  	generate
      	for (i = 0; i < 16; i = i + 1)
            begin: GP
              	PreProcessingGP GP (A[i], B[i], G[0][i], P[0][i]);
            end
    endgenerate

    // carry lookahead - layer 1
  	GrayCell #(.W(1)) GC1 (G[0][0], P[0][0], Cin, G[1][0]);
  	BlackCell #(.W(15)) BC1 (G[0][1:15], P[0][1:15], G[0][0:14], P[0][0:14], G[1][1:15], P[1][1:15]);
  
  	// carry lookahead - layer 2
  	GrayCell #(.W(2)) GC2 (G[1][1:2], P[1][1:2], {Cin, G[1][0]}, G[2][1:2]);
  	BlackCell #(.W(13)) BC2 (G[1][3:15], P[1][3:15], G[1][1:13], P[1][1:13], G[2][3:15], P[2][3:15]);
  
  	// carry lookahead - layer 3
    GrayCell #(.W(4)) GC3 (G[2][3:6], P[2][3:6], {Cin, G[1][0], G[2][1:2]}, G[3][3:6]);
    BlackCell #(.W(9)) BC3 (G[2][7:15], P[2][7:15], G[2][3:11], P[2][3:11], G[3][7:15], P[3][7:15]);
  
  	// carry lookahead - layer 4
  	GrayCell #(.W(8)) GC4 (G[3][7:14], P[3][7:14], {Cin, G[1][0], G[2][1:2], G[3][3:6]}, G[4][7:14]);
    BlackCell #(.W(1)) BC4 (G[3][15], P[3][15], G[3][7], P[3][7], G[4][15], P[4][15]);
  
  	// carry lookahead - layer 5
    GrayCell #(.W(1)) GC5 (G[4][15], P[4][15], Cin, Cout_i);
 
  	// post-processing - sum bits
  	assign S_i = ({Cin, G[1][0], G[2][1:2], G[3][3:6], G[4][7:14]} ^ P[0]);
  
    generate
        for (i = 0; i < 16; i = i + 1)
            begin: Adder16Bit
              	assign S[i] = S_i[i];
            end
    endgenerate
  
    // assign Cout
    assign Cout = Cout_i;
  
  	// overflow flag
    assign overflowFlag = (G[4][14] ^ Cout_i);
  
endmodule

//multiplier
module Mult16Bit(
  input signed [15:0] A,
  input signed [15:0] B,
  output signed [31:0]prod
);
  assign prod=A*B;
endmodule


//division
module division(
  input signed[15:0] A,
  input signed[15:0] B,
  output signed[15:0] Q,
  output signed[15:0] R
);
  assign Q=A/B;
  assign R=A%B;
endmodule

//nandop
module nandop(
  input [15:0]A,
  input [15:0]B,
  output [15:0]nandout
);
  assign andout=~(A&B);
endmodule

//norop
module norop(
  input [15:0]A,
  input [15:0]B,
  output [15:0]norout
);
  assign norout=~(A|B);
endmodule

//notop
module notop(
  input [15:0]A,
  output [15:0]A_not
);
  assign A_not=~A;
endmodule

//xorop
module xorop(
  input [15:0] A,
  input [15:0] B,
  output [15:0] xorout
);
  assign xorout=(A^B);
endmodule