`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 04:24:55 PM
// Design Name: 
// Module Name: decoder
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

module decoder(
    input logic [31:0] instructionCode,
    
    output opcode_t opcode,
    output logic [6:0] funct7,
    output logic [2:0] funct3,
    
    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd,
    
    output logic [31:0] immediate
);

assign opcode = opcode_t'(instructionCode[6:0]); // typecast instructionCode[6:0] to opcode_t
assign funct7 = instructionCode[31:25];
assign funct3 = instructionCode[14:12];

assign rs1 = instructionCode[19:15];
assign rs2 = instructionCode[24:20];
assign rd = instructionCode[11:7];

always_comb begin // set immediate values for each opcode type
    unique case (opcode_t'(instructionCode[6:0]))
        rTypeInstruction: immediate = 32'b0;
        
        iTypeInstruction,
        iTypeInstruction_LOAD,
        iTypeInstruction_JALR: immediate = {{20{instructionCode[31]}}, instructionCode[31:20]};
        
        sTypeInstruction: immediate = {{20{instructionCode[31]}}, instructionCode[31:25], instructionCode[11:7]};
        
        bTypeInstruction: immediate = {{19{instructionCode[31]}}, instructionCode[31], instructionCode[7], instructionCode[30:25], instructionCode[11:8], 1'b0};
        
        jTypeInstruction: immediate = {{11{instructionCode[31]}}, instructionCode[31], instructionCode[19:12], instructionCode[20], instructionCode[30:21], 1'b0};
        
        uTypeInstruction_LUI,
        uTypeInstruction_AUIPC: immediate = {instructionCode[31:12], 12'b0};
        
        default: immediate = 32'b0;
    endcase
end

endmodule
