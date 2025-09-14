`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 02:45:14 PM
// Design Name: 
// Module Name: tb_instructionMemory
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

module tb_instructionMemory;

logic [31:0] PC;
logic [31:0] instruction;

instructionMemory DUT (
    .PC(PC),
    .instruction(instruction)
);

initial begin
    DUT.instructionMem[0] = 32'h00500113;
    DUT.instructionMem[1] = 32'h00300193;
    DUT.instructionMem[2] = 32'h003100b3;
    DUT.instructionMem[3] = 32'h40310133;

    PC = 32'h0; #1;
    $display("PC = 0, expectedInstruction = 0x00500113, Instruction = %0h", instruction);
    PC = 32'h4; #1;
    $display("PC = 4, expectedInstruction = 0x00300193, Instruction = %0h", instruction);
    PC = 32'h8; #1;
    $display("PC = 8, expectedInstruction = 0x003100b3, Instruction = %0h", instruction);
    PC = 32'hC; #1;
    $display("PC = 12, expectedInstruction = 0x40310133, Instruction = %0h", instruction);
end

endmodule
