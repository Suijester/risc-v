`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/08/2025 02:04:52 PM
// Design Name: 
// Module Name: pipelinedDatapath
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

module pipelinedDatapath(
    input clk,
    input reset
);

// HAZARD DETECTION MODULE
logic pcEnable;
logic ifidEnable;
logic ifidClear;
logic idexClear;
logic exmemClear;

// Instruction Fetch Stage

logic [31:0] pcAddress_IF;
logic [31:0] pcPlusFour_IF;
logic [31:0] nextPC_IF;

logic [31:0] branchAddress_EX; // calculated in execute stage
logic [31:0] branchAddress_MEM;
logic takeBranch_MEM; // condition checked in memory stage

logic pcStallCache;
logic ifidCacheClear;

logic [31:0] instructionCode_IF;

assign pcPlusFour_IF = pcAddress_IF + 4;
assign nextPC_IF = (takeBranch_MEM) ? branchAddress_MEM : pcPlusFour_IF;

programCounter pcUnit (
    .clk(clk),
    .reset(reset),
    .nextPC(nextPC_IF),
    .pcEnable(pcEnable & ~pcStallCache),
    .pcAddress(pcAddress_IF)
);

logic writeCache_IF;
logic [3:0] writeIndex_IF;
logic [24:0] writeTag_IF;
logic [63:0] writeData_IF;

logic cacheHit_IF;
logic [31:0] cacheInstructionCode_IF;

l1Cache cacheUnit (
    .clk(clk),
    .reset(reset),

    .pcAddress(pcAddress_IF),
    .writeCache(writeCache_IF),
    .writeIndex(writeIndex_IF),
    .writeTag(writeTag_IF),
    .writeData(writeData_IF),

    .cacheHit(cacheHit_IF),
    .instructionCode(cacheInstructionCode_IF);
);

logic [31:0] fetchedInstructionCode;
logic instructionRequest;
logic [31:0] instructionAddress;
logic receivedInstruction;
logic [63:0] cacheData;

cacheController cacheControl (
    .clk(clk),
    .reset(reset),
    .cacheHit(cacheHit_IF),
    .pcAddress(pcAddress_IF),
    .fetchedData(cacheData)
    .pcStallCache(pcStallCache),
    .ifidCacheClear(ifidCacheClear),
    .writeIndex(writeIndex_IF),
    .writeTag(writeTag_IF),
    .instructionRequest(instructionRequest),
    .writeData(writeData_IF),

    .instructionAddress(instructionAddress),
    .receivedInstruction(receivedInstruction),
    .writeCache(writeCache_IF)
);

instructionMemory instructionUnit (
    .clk(clk),
    .reset(reset),
    .passedPC(instructionAddress),
    .instructionRequest(instructionRequest),
    .instruction(fetchedInstructionCode),
    .cacheData(cacheData),
    .receivedInstruction(receivedInstruction)
);

always_comb begin
    if (cacheHit_IF) begin
        instructionCode_IF = cacheInstructionCode_IF;
    end else if (receivedInstruction) begin
        instructionCode_IF = fetchedInstructionCode;
    end else begin
        instructionCode_IF = 32'h00000033;
    end
end

// IF/ID Register
logic [31:0] pcAddress_ID;
logic [31:0] instructionCode_ID;
logic [31:0] pcPlusFour_ID;

ifidRegister ifidUnit (
    .clk(clk),
    .reset(reset),
    .ifidEnable(ifidEnable),
    .ifidClear(ifidClear | ifidCacheClear),
    
    .pcAddress_IF(pcAddress_IF),
    .instructionCode_IF(instructionCode_IF),
    .pcPlusFour_IF(pcPlusFour_IF),
    
    .pcAddress_ID(pcAddress_ID),
    .instructionCode_ID(instructionCode_ID),
    .pcPlusFour_ID(pcPlusFour_ID)
);

// Instruction Decode Stage

// Addresses & Data
logic [4:0] r1Address_ID;
logic [4:0] r2Address_ID;
logic [31:0] r1Data_ID;
logic [31:0] r2Data_ID;
logic [31:0] immediate_ID;
logic [4:0] rdAddress_ID;

// PC Address & Instruction Data
logic [2:0] funct3_ID;
logic [6:0] funct7_ID;
opcode_t opcode_ID;

decoder decoderUnit (
    .instructionCode(instructionCode_ID),
    .opcode(opcode_ID),
    .funct7(funct7_ID),
    .funct3(funct3_ID),
    .rs1(r1Address_ID),
    .rs2(r2Address_ID),
    .rd(rdAddress_ID),
    .immediate(immediate_ID)
);

// Control Unit Data
ALU_operation_t operationALU_ID;
logic useImmediate_ID; // low only for r-type instructions
logic readMemory_ID; // load-type instructions
logic writeMemory_ID; // store-type instructions
logic writeRegister_ID; // any instruction that writes to rd
logic [1:0] writebackItem_ID; // 00 represents write result to reg, 01 represents write memory to register, 10 represents pc + 4 to rd
logic branch_ID; // b-type instructions
logic pcInputA_ID; // for jal & b-type instructions, use PC as Input A

controlUnit ctrlUnit (
    .opcode(opcode_ID),
    .funct7(funct7_ID),
    .funct3(funct3_ID),
    .operationALU(operationALU_ID),
    .useImmediate(useImmediate_ID),
    .readMemory(readMemory_ID),
    .writeMemory(writeMemory_ID),
    .writeRegister(writeRegister_ID),
    .writebackItem(writebackItem_ID),
    .branch(branch_ID),
    .pcInputA(pcInputA_ID)
);

logic writeRegister_WB;
logic [31:0] writeData_WB;
logic [4:0] rdAddress_WB;

registerFile regUnit (
    .clk(clk),
    .reset(reset),
    .r1Address(r1Address_ID),
    .r2Address(r2Address_ID),
    .r1Data(r1Data_ID),
    .r2Data(r2Data_ID),
    
    // can only write during writeback stage, so need those
    .writeRegister(writeRegister_WB),
    .writeAddress(rdAddress_WB),
    .writeData(writeData_WB)
);

// ID/EX Register

logic [4:0] r1Address_EX;
logic [4:0] r2Address_EX;
logic [31:0] r1Data_EX;
logic [31:0] r2Data_EX;
logic [31:0] immediate_EX;
logic [4:0] rdAddress_EX;
    
logic [31:0] pcAddress_EX;
logic [31:0] pcPlusFour_EX;
logic [2:0] funct3_EX;
logic [6:0] funct7_EX;
opcode_t opcode_EX;
    
ALU_operation_t operationALU_EX;
logic useImmediate_EX;
logic readMemory_EX;
logic writeMemory_EX;
logic writeRegister_EX;
logic [1:0] writebackItem_EX;
logic branch_EX;
logic pcInputA_EX;

logic [1:0] forwardItemA_EX;
logic [1:0] forwardItemB_EX;

idexRegister idexUnit (
    .clk(clk),
    .reset(reset),
    .idexClear(idexClear),
    
    .r1Address_ID(r1Address_ID),
    .r2Address_ID(r2Address_ID),
    .r1Data_ID(r1Data_ID),
    .r2Data_ID(r2Data_ID),
    .immediate_ID(immediate_ID),
    .rdAddress_ID(rdAddress_ID),
    .pcAddress_ID(pcAddress_ID),
    .pcPlusFour_ID(pcPlusFour_ID),
    .funct3_ID(funct3_ID),
    .funct7_ID(funct7_ID),
    .opcode_ID(opcode_ID),
    
    .operationALU_ID(operationALU_ID),
    .useImmediate_ID(useImmediate_ID),
    .readMemory_ID(readMemory_ID),
    .writeMemory_ID(writeMemory_ID),
    .writeRegister_ID(writeRegister_ID),
    .writebackItem_ID(writebackItem_ID),
    .branch_ID(branch_ID),
    .pcInputA_ID(pcInputA_ID),
    
    .r1Address_EX(r1Address_EX),
    .r2Address_EX(r2Address_EX),
    .r1Data_EX(r1Data_EX),
    .r2Data_EX(r2Data_EX),
    .immediate_EX(immediate_EX),
    .rdAddress_EX(rdAddress_EX),
    .pcAddress_EX(pcAddress_EX),
    .pcPlusFour_EX(pcPlusFour_EX),
    .funct3_EX(funct3_EX),
    .funct7_EX(funct7_EX),
    .opcode_EX(opcode_EX),
    
    .operationALU_EX(operationALU_EX),
    .useImmediate_EX(useImmediate_EX),
    .readMemory_EX(readMemory_EX),
    .writeMemory_EX(writeMemory_EX),
    .writeRegister_EX(writeRegister_EX),
    .writebackItem_EX(writebackItem_EX),
    .branch_EX(branch_EX),
    .pcInputA_EX(pcInputA_EX)
);

// Execute Stage
logic [31:0] aluInputA_EX;
logic [31:0] aluInputB_EX;
logic aluZero_EX;
logic [31:0] aluResult_EX;
logic [31:0] alternateBranchAddr_EX;

logic [31:0] forwardedDataA_EX;
logic [31:0] forwardedDataB_EX;

logic [31:0] memWriteData_EX;

logic [31:0] pcPlusFour_MEM;
logic [31:0] aluResult_MEM;
logic [31:0] readData_MEM;
logic [1:0] writebackItem_MEM;

always_comb begin
    unique case (writebackItem_MEM)
        2'b00: memWriteData_EX = aluResult_MEM;
        2'b01: memWriteData_EX = readData_MEM;
        2'b10: memWriteData_EX = pcPlusFour_MEM;
        default: memWriteData_EX = 32'b0;
    endcase
end

always_comb begin
    unique case (forwardItemA_EX)
        2'b00:  forwardedDataA_EX = r1Data_EX;
        2'b01:  forwardedDataA_EX = memWriteData_EX;
        2'b10:  forwardedDataA_EX = writeData_WB;
        default: forwardedDataA_EX = r1Data_EX;
    endcase
end

always_comb begin
    unique case (forwardItemB_EX)
        2'b00:  forwardedDataB_EX = r2Data_EX;
        2'b01:  forwardedDataB_EX = memWriteData_EX;
        2'b10:  forwardedDataB_EX = writeData_WB;
        default: forwardedDataB_EX = r2Data_EX;
    endcase
end

assign alternateBranchAddr_EX = pcAddress_EX + immediate_EX; // b-type instructions
assign aluInputA_EX = (pcInputA_EX) ? pcAddress_EX : forwardedDataA_EX;
assign aluInputB_EX = (useImmediate_EX) ? immediate_EX : forwardedDataB_EX;
assign branchAddress_EX = (opcode_EX == bTypeInstruction) ? alternateBranchAddr_EX : aluResult_EX;

ALU aluUnit (
    .operation(operationALU_EX),
    .A(aluInputA_EX),
    .B(aluInputB_EX),
    
    .result(aluResult_EX),
    .zero(aluZero_EX)
);

// EX/MEM Register
opcode_t opcode_MEM;
logic [2:0] funct3_MEM;

logic aluZero_MEM;
logic [31:0] r2Data_MEM; // for store-type instructions
logic [4:0] rdAddress_MEM;
logic [31:0] pcAddress_MEM;

logic writeRegister_MEM;
logic branch_MEM;
logic readMemory_MEM;
logic writeMemory_MEM;

exmemRegister exmemUnit (
    .clk(clk),
    .reset(reset),
    .exmemClear(exmemClear),
    
    .opcode_EX(opcode_EX),
    .funct3_EX(funct3_EX),
    .branchAddress_EX(branchAddress_EX),
    .aluResult_EX(aluResult_EX),
    .aluZero_EX(aluZero_EX),
    .r2Data_EX(forwardedDataB_EX),
    .rdAddress_EX(rdAddress_EX),
    .pcPlusFour_EX(pcPlusFour_EX),
    .pcAddress_EX(pcAddress_EX),
    .writeRegister_EX(writeRegister_EX),
    .branch_EX(branch_EX),
    .readMemory_EX(readMemory_EX),
    .writeMemory_EX(writeMemory_EX),
    .writebackItem_EX(writebackItem_EX),
    
    .opcode_MEM(opcode_MEM),
    .funct3_MEM(funct3_MEM),
    .branchAddress_MEM(branchAddress_MEM),
    .aluResult_MEM(aluResult_MEM),
    .aluZero_MEM(aluZero_MEM),
    .r2Data_MEM(r2Data_MEM),
    .rdAddress_MEM(rdAddress_MEM),
    .pcPlusFour_MEM(pcPlusFour_MEM),
    .pcAddress_MEM(pcAddress_MEM),
    .writeRegister_MEM(writeRegister_MEM),
    .branch_MEM(branch_MEM),
    .readMemory_MEM(readMemory_MEM),
    .writeMemory_MEM(writeMemory_MEM),
    .writebackItem_MEM(writebackItem_MEM)
);

// Memory Access Stage
logic metCondition_MEM;

always_comb begin // determine conditional jump success
    metCondition_MEM = 0;
    if (opcode_MEM == bTypeInstruction) begin
        unique case (funct3_MEM)
            3'h0: metCondition_MEM = aluZero_MEM;
            3'h1: metCondition_MEM = ~aluZero_MEM;
            3'h4: metCondition_MEM = aluResult_MEM[0];
            3'h5: metCondition_MEM = ~aluResult_MEM[0];
            3'h6: metCondition_MEM = aluResult_MEM[0];
            3'h7: metCondition_MEM = ~aluResult_MEM[0];
            default: metCondition_MEM = 0;
        endcase
    end
end

assign takeBranch_MEM = ((metCondition_MEM & branch_MEM) | (opcode_MEM == jTypeInstruction) | (opcode_MEM == iTypeInstruction_JALR));

dataMemory dataUnit (
    .clk(clk),
    .address(aluResult_MEM),
    .readData(readData_MEM),
    .readMemory(readMemory_MEM),
    .funct3(funct3_MEM),
    .writeMemory(writeMemory_MEM),
    .writeData(r2Data_MEM)
);

// MEM/WB Register
logic [31:0] readData_WB;
logic [31:0] pcPlusFour_WB;
logic [31:0] aluResult_WB;
logic [1:0] writebackItem_WB;

memwbRegister memwbUnit (
    .clk(clk),
    .reset(reset),
    .readData_MEM(readData_MEM),
    .pcPlusFour_MEM(pcPlusFour_MEM),
    .writeRegister_MEM(writeRegister_MEM),
    .aluResult_MEM(aluResult_MEM),
    .rdAddress_MEM(rdAddress_MEM),
    .writebackItem_MEM(writebackItem_MEM),
    
    .readData_WB(readData_WB),
    .pcPlusFour_WB(pcPlusFour_WB),
    .writeRegister_WB(writeRegister_WB),
    .aluResult_WB(aluResult_WB),
    .rdAddress_WB(rdAddress_WB),
    .writebackItem_WB(writebackItem_WB)
);

// Writeback Stage

always_comb begin // determine what to write to destination register
    unique case (writebackItem_WB)
        2'b00: writeData_WB = aluResult_WB;
        2'b01: writeData_WB = readData_WB;
        2'b10: writeData_WB = pcPlusFour_WB;
        default: writeData_WB = 32'b0;
    endcase
end

hazardModule hazardUnit (
    .r1Address_ID(r1Address_ID),
    .r2Address_ID(r2Address_ID),
    
    .r1Address_EX(r1Address_EX),
    .r2Address_EX(r2Address_EX),
    
    .rdAddress_EX(rdAddress_EX),
    .readMemory_EX(readMemory_EX),
    .writeRegister_EX(writeRegister_EX),
    
    .rdAddress_MEM(rdAddress_MEM),
    .writeRegister_MEM(writeRegister_MEM),
    .takeBranch_MEM(takeBranch_MEM),
    
    .rdAddress_WB(rdAddress_WB),
    .writeRegister_WB(writeRegister_WB),
    
    .forwardItemA_EX(forwardItemA_EX),
    .forwardItemB_EX(forwardItemB_EX),
    .pcEnable(pcEnable),
    .ifidEnable(ifidEnable),
    .ifidClear(ifidClear),
    .idexClear(idexClear),
    .exmemClear(exmemClear)
);

endmodule
