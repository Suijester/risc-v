`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 02:43:40 PM
// Design Name: 
// Module Name: exmemRegister
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

module exmemRegister(
    input logic clk,
    input logic reset,
    input logic exmemClear,
    
    input opcode_t opcode_EX,
    input logic [2:0] funct3_EX,
    
    input logic [31:0] branchAddress_EX,
    input logic [31:0] aluResult_EX,
    input logic aluZero_EX,
    input logic [31:0] r2Data_EX, // for store-type instructions
    input logic [4:0] rdAddress_EX,
    input logic [31:0] pcPlusFour_EX,
    input logic [31:0] pcAddress_EX, // for pc = pc + imm (alternate branch address for b-types)
    
    input logic writeRegister_EX,
    input logic branch_EX,
    input logic readMemory_EX,
    input logic writeMemory_EX,
    input logic [1:0] writebackItem_EX,
    
    output opcode_t opcode_MEM,
    output logic [2:0] funct3_MEM,
    
    output logic [31:0] branchAddress_MEM,
    output logic [31:0] aluResult_MEM,
    output logic aluZero_MEM,
    output logic [31:0] r2Data_MEM, // for store-type instructions
    output logic [4:0] rdAddress_MEM,
    output logic [31:0] pcPlusFour_MEM,
    output logic [31:0] pcAddress_MEM,
    
    output logic writeRegister_MEM,
    output logic branch_MEM,
    output logic readMemory_MEM,
    output logic writeMemory_MEM,
    output logic [1:0] writebackItem_MEM
);

always_ff @(posedge clk or negedge reset) begin
    if (!reset | exmemClear) begin
        opcode_MEM <= emptyType;
        funct3_MEM <= 0;
        
        branchAddress_MEM <= 0;
        aluResult_MEM <= 0;
        aluZero_MEM <= 0;
        r2Data_MEM <= 0;
        rdAddress_MEM <= 0;
        pcPlusFour_MEM <= 0;
        pcAddress_MEM <= 0;
        writeRegister_MEM <= 0;
        branch_MEM <= 0;
        readMemory_MEM <= 0;
        writeMemory_MEM <= 0;
        writebackItem_MEM <= 0;
    end else begin
        opcode_MEM <= opcode_EX;
        funct3_MEM <= funct3_EX;
        
        branchAddress_MEM <= branchAddress_EX;
        aluResult_MEM <= aluResult_EX;
        aluZero_MEM <= aluZero_EX;
        r2Data_MEM <= r2Data_EX;
        rdAddress_MEM <= rdAddress_EX;
        pcPlusFour_MEM <= pcPlusFour_EX;
        pcAddress_MEM <= pcAddress_EX;
        writeRegister_MEM <= writeRegister_EX;
        branch_MEM <= branch_EX;
        readMemory_MEM <= readMemory_EX;
        writeMemory_MEM <= writeMemory_EX;
        writebackItem_MEM <= writebackItem_EX;
    end
end
endmodule
