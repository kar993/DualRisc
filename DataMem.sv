`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.04.2024 11:39:09
// Design Name: 
// Module Name: DataMem
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module DataMem(clk,wd,din,addr,dout);
//wd=1 write else read
input reg clk,wd;
input reg [15:0]din;
input reg [7:0] addr;
output reg [15:0] dout;
reg [255:0]RAM[15:0];

always@(posedge clk)begin
    if(wd)begin 
        RAM[addr]<=din;
        dout<=din;
    end
    else begin
    dout<=RAM[addr];
    
    end

end




endmodule
