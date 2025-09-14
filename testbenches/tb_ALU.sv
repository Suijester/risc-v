`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 09:49:16 AM
// Design Name: 
// Module Name: tb_ALU
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
`include "enumTypes.svh"

module tb_ALU;

ALU_operation_t operation;
logic [31:0] A;
logic [31:0] B;

logic [31:0] result;
logic zero;

ALU dut(
    .operation(operation),
    .A(A),
    .B(B),
    .result(result),
    .zero(zero)
);

task verifyResult(string testDescription, logic [31:0] expectedResult);
    #1;
    if (result == expectedResult) begin
        $display("Passed | Test: %s | Result: %0d | Operation: %s", testDescription, expectedResult, operation.name());
    end else begin
        $error("Fail | Test: %s | Result: %0d | Expected Result: %0d | Operation: %s", testDescription, result, expectedResult, operation.name());
    end
endtask

initial begin
    // add 15, 20 (expected 35)
    operation = addALU;
    A = 15;
    B = 20;
    verifyResult("ADD 15, 20", 35);
    
    // subtract 10, 10 (zero flag high, expected 0)
    operation = subALU;
    A = 10;
    B = 10;
    verifyResult("SUB 10, 10", 0);
    
    // XOR 0b100, 0b110 (expected 0b010, or 2)
    operation = xorALU;
    A = 32'b100;
    B = 32'b110;
    verifyResult("XOR 0b100, 0b110", 2);
    
    // OR 0b010, 0b101 (expected 0b011, or 3)
    operation = orALU;
    A = 32'b010;
    B = 32'b011;
    verifyResult("OR 0b010, 0b011", 3);
    
    // AND 0b011, 0b111 (expected 0b011, or 3)
    operation = andALU;
    A = 32'b011;
    B = 32'b111;
    verifyResult("AND 0b011, 0b111", 3);
    
    // SLL 0b001, 2 (expected 0b100, or 4)
    operation = sllALU;
    A = 32'b001;
    B = 2;
    verifyResult("SLL 0b001, 2", 4);
    
    // SRL 0b100, 2 (expected 0b001, or 1)
    operation = srlALU;
    A = 32'b100;
    B = 2;
    verifyResult("SLL 0b100, 2", 1);
    
    // SRA 0x80000000, 2 (expected 0xE0000000, or 3758096384)
    operation = sraALU;
    A = 32'h80000000;
    B = 2;
    verifyResult("SRA 0x80000000, 2", 32'hE0000000);
    
    // SLT -5, 2 (expected 1)
    operation = sltALU;
    A = -5;
    B = 2;
    verifyResult("SLT -5, 2", 1);
    
    // SLTU -5, 2 (expected 0)
    operation = sltuALU;
    A = -5; // will underflow, since A is treated as unsigned
    B = 2;
    verifyResult("SLTU -5, 2", 0);
end

endmodule