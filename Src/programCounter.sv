`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 06:13:51 PM
// Design Name: 
// Module Name: programCounter
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

module programCounter(
    input logic clk,
    input logic reset,
    
    input logic takeBranch,
    input logic [31:0] branchAddress,
    output logic [31:0] pcAddress

);

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        pcAddress <= 32'b0;
    end else if (takeBranch) begin
        pcAddress <= branchAddress;
    end else begin
        pcAddress <= pcAddress + 4;
    end
end

endmodule
