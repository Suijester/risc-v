`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 09:52:04 AM
// Design Name: 
// Module Name: tb_decoder
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

module tb_decoder;

logic [31:0] instructionCode;
    
opcode_t opcode;
logic [6:0] funct7;
logic [3:0] funct3;
    
logic [4:0] rs1;
logic [4:0] rs2;
logic [4:0] rd;
    
logic [31:0] immediate;

decoder DUT(
    .instructionCode(instructionCode),
    .opcode(opcode),
    .funct7(funct7),
    .funct3(funct3),
    .rs1(rs1),
    .rs2(rs2),
    .rd(rd),
    .immediate(immediate)
);

task verifyCode(string testDescription, opcode_t expectedCode, logic [6:0] expectedFunct7, logic [2:0] expectedFunct3, logic [4:0] expectedRs1, logic [4:0] expectedRs2, logic [4:0] expectedRd, logic [31:0] expectedImmediate);
    #1;
    if (opcode == expectedCode && funct7 == expectedFunct7 
    && funct3 == expectedFunct3 && rs1 == expectedRs1 
    && rs2 == expectedRs2 && rd == expectedRd 
    && immediate == expectedImmediate) begin
        $display("Passed | Test: %s | Opcode: %s", testDescription, opcode.name());
    end else begin
        $error("Fail | Test: %s", testDescription);
        if (opcode != expectedCode) $display("Incorrect Opcode | Expected: %s | Actual: %s", expectedCode.name(), opcode.name());
        
        if (funct7 != expectedFunct7) $display("Incorrect Funct7 | Expected: %0d | Actual: %0d", expectedFunct7, funct7);
        if (funct3 != expectedFunct3) $display("Incorrect Funct3 | Expected: %0d | Actual: %0d", expectedFunct3, funct3);
        
        if (rs1 != expectedRs1) $display("Incorrect rs1 | Expected: %0d | Actual: %0d", expectedRs1, rs1);
        if (rs2 != expectedRs2) $display("Incorrect rs2 | Expected: %0d | Actual: %0d", expectedRs2, rs2);
        if (rd != expectedRd) $display("Incorrect rd | Expected: %0d | Actual: %0d", expectedRd, rd);
        
        if (immediate != expectedImmediate) $display("Incorrect Immediate | Expected: %0d | Actual: %0d", expectedImmediate, immediate);
    end
endtask

initial begin
    instructionCode = 32'h002081b3; // ADD x3, x1, x2
    verifyCode("R-Type ADD", rTypeInstruction, 7'h00, 3'h0, 1, 2, 3, 32'h0);
    
    instructionCode = 32'h00508113; // ADDI x2, x1, 5
    verifyCode("I-Type ADDI", iTypeInstruction, 7'h00, 3'h0, 1, 5, 2, 32'h5);

    instructionCode = 32'h0100a103; // LW x2, 16(x1)
    verifyCode("Load LW", iTypeInstruction_LOAD, 7'h00, 3'h2, 1, 5'h10, 2, 32'h10);

    instructionCode = 32'h0020a823; // SW x2, 16(x1)
    verifyCode("Store SW", sTypeInstruction, 7'h00, 3'h2, 1, 2, 16, 32'h10);

    instructionCode = 32'hFE2086E3; // BEQ x1, x2, -20
    verifyCode("Branch BEQ", bTypeInstruction, 7'h7f, 3'h0, 1, 2, 13, 32'hffffffec);
        
    instructionCode = 32'h020000ef; // JAL x1, 32
    verifyCode("J-Type JAL", jTypeInstruction, 7'h01, 3'h0, 0, 0, 1, 32'h20);

    instructionCode = 32'h123450b7; // LUI x1, 0x12345
    verifyCode("U-Type LUI", uTypeInstruction_LUI, 7'h9, 3'h5, 8, 3, 1, 32'h12345000);

    instructionCode = 32'h12345097; // AUIPC x1, 0x12345
    verifyCode("U-Type AUIPC", uTypeInstruction_AUIPC, 7'h9, 3'h5, 8, 3, 1, 32'h12345000);

    instructionCode = 32'h010100e7; // JALR x1, x2, 16
    verifyCode("I-Type JALR", iTypeInstruction_JALR, 7'h00, 3'h0, 2, 16, 1, 32'h10);
end

endmodule