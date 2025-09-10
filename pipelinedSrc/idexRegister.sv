`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 02:23:42 PM
// Design Name: 
// Module Name: idexRegister
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

module idexRegister(
    input logic clk,
    input logic reset,
    input logic idexClear,
    
    input logic [4:0] r1Address_ID,
    input logic [4:0] r2Address_ID,
    input logic [31:0] r1Data_ID,
    input logic [31:0] r2Data_ID,
    input logic [31:0] immediate_ID,
    input logic [4:0] rdAddress_ID,

    input logic [31:0] pcAddress_ID,
    input logic [31:0] pcPlusFour_ID,
    input logic [2:0] funct3_ID,
    input logic [6:0] funct7_ID,
    input opcode_t opcode_ID,
    
    input ALU_operation_t operationALU_ID,
    input logic useImmediate_ID, // low only for r-type instructions
    input logic readMemory_ID, // load-type instructions
    input logic writeMemory_ID, // store-type instructions
    input logic writeRegister_ID, // any instruction that writes to rd
    input logic [1:0] writebackItem_ID, // 00 represents write result to reg, 01 represents write memory to register, 10 represents pc + 4 to rd
    input logic branch_ID, // b-type instructions
    input logic pcInputA_ID, // for jal & b-type instructions, use PC as Input A
    
    output logic [4:0] r1Address_EX,
    output logic [4:0] r2Address_EX,
    output logic [31:0] r1Data_EX,
    output logic [31:0] r2Data_EX,
    output logic [31:0] immediate_EX,
    output logic [4:0] rdAddress_EX,
    
    output logic [31:0] pcAddress_EX,
    output logic [31:0] pcPlusFour_EX,
    output logic [2:0] funct3_EX,
    output logic [6:0] funct7_EX,
    output opcode_t opcode_EX,
    
    output ALU_operation_t operationALU_EX,
    output logic useImmediate_EX,
    output logic readMemory_EX,
    output logic writeMemory_EX,
    output logic writeRegister_EX,
    output logic [1:0] writebackItem_EX,
    output logic branch_EX,
    output logic pcInputA_EX
);

always_ff @(posedge clk or negedge reset) begin
    if (!reset | idexClear) begin
        r1Address_EX <= 0;
        r2Address_EX <= 0;
        r1Data_EX <= 0;
        r2Data_EX <= 0;
        immediate_EX <= 0;
        rdAddress_EX <= 0;
        
        pcAddress_EX <= 0;
        pcPlusFour_EX <= 0;
        funct3_EX <= 0;
        funct7_EX <= 0;
        opcode_EX <= emptyType;
        
        operationALU_EX <= noALU;
        useImmediate_EX <= 0;
        readMemory_EX <= 0;
        writeMemory_EX <= 0;
        writeRegister_EX <= 0;
        writebackItem_EX <= 0;
        branch_EX <= 0;
        pcInputA_EX <= 0;
    end else begin
        r1Address_EX <= r1Address_ID;
        r2Address_EX <= r2Address_ID;
        r1Data_EX <= r1Data_ID;
        r2Data_EX <= r2Data_ID;
        immediate_EX <= immediate_ID;
        rdAddress_EX <= rdAddress_ID;
    
        pcAddress_EX <= pcAddress_ID;
        pcPlusFour_EX <= pcPlusFour_ID;
        funct3_EX <= funct3_ID;
        funct7_EX <= funct7_ID;
        opcode_EX <= opcode_ID;
        
        operationALU_EX <= operationALU_ID;
        useImmediate_EX <= useImmediate_ID;
        readMemory_EX <= readMemory_ID;
        writeMemory_EX <= writeMemory_ID;
        writeRegister_EX <= writeRegister_ID;
        writebackItem_EX <= writebackItem_ID;
        branch_EX <= branch_ID;
        pcInputA_EX <= pcInputA_ID;
    end
end

endmodule
