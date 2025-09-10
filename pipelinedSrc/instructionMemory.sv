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

logic [31:0] instructionMem [0:memorySize - 1];


assign instruction = instructionMem[PC[31:2]];

initial begin
    instructionMem[0] = 32'h00500113;  // addi x2, x0, 5
    instructionMem[1] = 32'h00300193;  // addi x3, x0, 3
    instructionMem[2] = 32'h003100b3;  // add x1, x2, x3
    instructionMem[3] = 32'h40310133;  // sub x2, x2, x3
    instructionMem[4] = 32'h00108093;  // addi x1, x1, 1
    instructionMem[5] = 32'hfe510ee3;  // bne x2, x0, -4 (loop back)
    instructionMem[6] = 32'h005002b3;  // add x5, x1, x0 (store result in x5)
end

endmodule