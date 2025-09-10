`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 02:07:22 PM
// Design Name: 
// Module Name: instructionMemory
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

module instructionMemory #(
    parameter memorySize = 64
)(
    input logic [31:0] PC,
    output logic [31:0] instruction
);

logic [31:0] instructionMem [0:memorySize - 1] = '{default: 32'b0};
assign instruction = instructionMem[PC[31:2]];

/* initial begin
    instructionMem[0] = 32'h00500113;  // ADDI x2, x0, 5 (load immediate 5 into x2)
    instructionMem[1] = 32'h00300193;  // ADDI x3, x0, 3 (load immediate 3 into x3)
    instructionMem[2] = 32'h003100b3;  // ADD  x1, x2, x3 (x1 = x2 + x3 = 8)
    instructionMem[3] = 32'h40310133;  // SUB  x2, x2, x3 (x2 = x2 - x3 = 2)
end */

endmodule