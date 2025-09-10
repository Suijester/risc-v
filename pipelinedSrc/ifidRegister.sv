`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 01:58:13 PM
// Design Name: 
// Module Name: ifidRegister
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


module ifidRegister(
    input logic clk,
    input logic reset,
    input logic ifidEnable,
    input logic ifidClear,
    
    input logic [31:0] pcAddress_IF,
    input logic [31:0] instructionCode_IF,
    input logic [31:0] pcPlusFour_IF,
    
    output logic [31:0] pcAddress_ID,
    output logic [31:0] instructionCode_ID,
    output logic [31:0] pcPlusFour_ID
);

always_ff @(posedge clk or negedge reset) begin
    if (!reset | ifidClear) begin
        instructionCode_ID <= 0;
        pcPlusFour_ID <= 0;
        pcAddress_ID <= 0;
    end else if (ifidEnable) begin
        pcPlusFour_ID <= pcPlusFour_IF;
        instructionCode_ID <= instructionCode_IF;
        pcAddress_ID <= pcAddress_IF;
    end
end

endmodule
