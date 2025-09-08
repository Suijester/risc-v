`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 02:35:54 PM
// Design Name: 
// Module Name: tb_decode_control
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

module tb_decode_control;

logic [31:0] instructionCode;
    
opcode_t opcode;
logic [6:0] funct7;
logic [3:0] funct3;
    
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
    
logic [31:0] immediate;
logic useImmediate;
logic readMemory;
logic writeMemory;
logic writeRegister;
logic [1:0] writebackItem;
logic branch;
logic pcInputA;
ALU_operation_t operationALU;

decoder decodeUnit (
    .instructionCode(instructionCode),
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .immediate(immediate)
);

controlUnit DUT (
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

task verifySignals(string testDescription, logic expuseImmediate, logic expreadMemory, logic expwriteMemory, logic expwriteRegister, logic [1:0] expwritebackItem, logic expbranch, logic expPC, ALU_operation_t expALU);
    #1;
    if (useImmediate == expuseImmediate && readMemory == expreadMemory && writeMemory == expwriteMemory
    && writeRegister == expwriteRegister && writebackItem == expwritebackItem && operationALU == expALU
    && branch == expbranch && pcInputA == expPC) begin
        $display("Passed | Test: %s | Opcode: %s", testDescription, opcode.name());
    end else begin
        $error("Fail | Test: %s", testDescription);
        if (useImmediate != expuseImmediate) $display("Incorrect Immediate | Expected: %d | Actual: %d", expuseImmediate, useImmediate);
        if (readMemory != expreadMemory) $display("Incorrect readMemory | Expected: %d | Actual: %d", expreadMemory, readMemory);
        if (writeMemory != expwriteMemory) $display("Incorrect writeMemory | Expected: %d | Actual: %d", expwriteMemory, writeMemory);
        if (writeRegister != expwriteRegister) $display("Incorrect writeRegister | Expected: %d | Actual: %d", expwriteRegister, writeRegister);
        if (writebackItem != expwritebackItem) $display("Incorrect writebackItem | Expected: %d | Actual: %d", expwritebackItem, writebackItem);
        if (branch != expbranch) $display("Incorrect branch | Expected: %d | Actual: %d", expbranch, branch);
        if (pcInputA != expPC) $display("Incorrect pcInputA | Expected: %d | Actual: %d", expPC, pcInputA);
        if (operationALU != expALU) $display("Incorrect operation | Expected: %s | Actual: %s", expALU.name(), operationALU.name());
    end
endtask

initial begin
    // R-Type ADD
    instructionCode = 32'h002081b3;
    verifySignals("R-Type ADD", 0, 0, 0, 1, 0, 0, 0, addALU);
    
    // I-Type ADDI
    instructionCode = 32'h00508113;
    verifySignals("I-Type ADDI", 1, 0, 0, 1, 0, 0, 0, addALU);

    // I-Type LW
    instructionCode = 32'h0100a103;
    verifySignals("Load LW", 1, 1, 0, 1, 1, 0, 0, addALU);

    // S-Type SW
    instructionCode = 32'h0020a823;
    verifySignals("Store SW", 1, 0, 1, 0, 0, 0, 0, addALU);
    
    // B-Type BEQ
    instructionCode = 32'hFE2086E3;
    verifySignals("Branch BEQ", 0, 0, 0, 0, 0, 1, 0, subALU);
    
    // J-Type JAL
    instructionCode = 32'h020000ef;
    verifySignals("J-Type JAL", 1, 0, 0, 1, 2, 1, 1, addALU);

    // U-Type LUI
    instructionCode = 32'h123450b7;
    verifySignals("U-Type LUI", 1, 0, 0, 1, 0, 0, 0, luiALU);

    // U-Type AUIPC
    instructionCode = 32'h12345097;
    verifySignals("U-Type AUIPC", 1, 0, 0, 1, 0, 0, 0, addALU);

    // I-Type JALR
    instructionCode = 32'h010100e7;
    verifySignals("I-Type JALR", 1, 0, 0, 1, 2, 1, 0, addALU);
end

endmodule
