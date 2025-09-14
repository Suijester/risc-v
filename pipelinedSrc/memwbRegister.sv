`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 04:37:58 PM
// Design Name: 
// Module Name: memwbRegister
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

module memwbRegister(
    input logic clk,
    input logic reset,
    
    input logic [31:0] readData_MEM,
    input logic [31:0] pcPlusFour_MEM,
    input logic writeRegister_MEM,
    input logic [31:0] aluResult_MEM,
    input logic [4:0] rdAddress_MEM,
    input logic [1:0] writebackItem_MEM,
    
    output logic [31:0] readData_WB,
    output logic [31:0] pcPlusFour_WB,
    output logic writeRegister_WB,
    output logic [31:0] aluResult_WB,
    output logic [4:0] rdAddress_WB,
    output logic [1:0] writebackItem_WB
);

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        readData_WB <= 0;
        pcPlusFour_WB <= 0;
        writeRegister_WB <= 0;
        aluResult_WB <= 0;
        rdAddress_WB <= 0;
        writebackItem_WB <= 0;
    end else begin
        readData_WB <= readData_MEM;
        pcPlusFour_WB <= pcPlusFour_MEM;
        writeRegister_WB <= writeRegister_MEM;
        aluResult_WB <= aluResult_MEM;
        rdAddress_WB <= rdAddress_MEM;
        writebackItem_WB <= writebackItem_MEM;
    end
end

endmodule
