`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 03:38:03 PM
// Design Name: 
// Module Name: datapath
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

module datapath (
    input clk,
    input reset
);

// Control Unit Signals
logic useImmediate;
logic readMemory;
logic writeMemory;
logic writeRegister;
logic [1:0] writebackItem;
logic branch;
logic pcInputA;
ALU_operation_t operationALU;

// Branch Evaluator Outputs
logic branchCondition;
logic takeBranch;

// Program Counter Addresses
logic [31:0] pcAddress;
logic [31:0] branchAddress;

// Instruction Memory Output
logic [31:0] instructionCode;

// Decoder Outputs
opcode_t opcode;
logic [6:0] funct7;
logic [2:0] funct3;
logic [31:0] immediate;
logic [4:0] rs1Address;
logic [4:0] rs2Address;
logic [4:0] rdAddress;

// Register Data
logic [31:0] r1Data;
logic [31:0] r2Data;
logic [31:0] writeData;

// ALU Inputs
logic [31:0] aluInputA;
logic [31:0] aluInputB;
logic [31:0] aluResult;
logic aluZero;

// Loaded-Data from Data Memory
logic [31:0] readDataMemory;

// new logic item, determines whether the b-type condition was met
logic metCondition;
logic [31:0] pcPlusFour; // rd = pc + 4 (for jal & jalr)
logic [31:0] alternateBranchAddr; // pc += imm, cant be calculated by alu for branches (alu needs to check condition)

assign pcPlusFour = (pcAddress + 4);
assign alternateBranchAddr = (pcAddress + immediate);

programCounter pcUnit (
    .clk(clk),
    .reset(reset),
    .takeBranch(takeBranch),
    .branchAddress(branchAddress),
    .pcAddress(pcAddress)
);

instructionMemory instructionUnit (
    .PC(pcAddress),
    .instruction(instructionCode)
);

decoder decoderUnit (
    .instructionCode(instructionCode),
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .rs1(rs1Address),
    .rs2(rs2Address),
    .rd(rdAddress),
    .immediate(immediate)
);

controlUnit controllerUnit (
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .operationALU(operationALU),
    .useImmediate(useImmediate),
    .readMemory(readMemory),
    .writeMemory(writeMemory),
    .writeRegister(writeRegister),
    .writebackItem(writebackItem),
    .branch(branch),
    .pcInputA(pcInputA)
);

registerFile registerUnit (
    .clk(clk),
    .reset(reset),
    .r1Address(rs1Address),
    .r2Address(rs2Address),
    .r1Data(r1Data),
    .r2Data(r2Data),
    .writeRegister(writeRegister),
    .writeAddress(rdAddress),
    .writeData(writeData)
);

assign aluInputA = (pcInputA) ? pcAddress : r1Data;
assign aluInputB = (useImmediate) ? immediate : r2Data;

ALU aluUnit(
    .operation(operationALU),
    .A(aluInputA),
    .B(aluInputB),
    .result(aluResult),
    .zero(aluZero)
);

dataMemory dataUnit (
    .clk(clk),
    .address(aluResult),
    .readData(readDataMemory),
    .readMemory(readMemory),
    .writeMemory(writeMemory),
    .writeData(r2Data),
    .funct3(funct3)
);

// MUX Logic
assign branchAddress = (opcode == bTypeInstruction) ? alternateBranchAddr : aluResult; // alternate branch address for b-type instructions

always_comb begin // determine conditional jump success
    metCondition = 0;
    if (opcode == bTypeInstruction) begin
        unique case (funct3)
            3'h0: metCondition = aluZero;
            3'h1: metCondition = ~aluZero;
            3'h4: metCondition = aluResult[0];
            3'h5: metCondition = ~aluResult[0];
            3'h6: metCondition = aluResult[0];
            3'h7: metCondition = ~aluResult[0];
            default: metCondition = 0;
        endcase
    end
end

assign takeBranch = (metCondition | (opcode == jTypeInstruction) | (opcode == iTypeInstruction_JALR));

always_comb begin // determine what to write to destination register
    unique case (writebackItem)
        2'b00: writeData = aluResult;
        2'b01: writeData = readDataMemory;
        2'b10: writeData = pcPlusFour;
        default: writeData = 32'b0;
    endcase
end


endmodule