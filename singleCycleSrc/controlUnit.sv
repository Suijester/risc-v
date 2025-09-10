`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 04:24:55 PM
// Design Name: 
// Module Name: controlUnit
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

module controlUnit(
    input opcode_t opcode,
    input logic [6:0] funct7,
    input logic [2:0] funct3,
    
    output ALU_operation_t operationALU,
    output logic useImmediate, // low only for r-type instructions
    output logic readMemory, // load-type instructions
    output logic writeMemory, // store-type instructions
    output logic writeRegister, // any instruction that writes to rd
    output logic [1:0] writebackItem, // 00 represents write result to reg, 01 represents write memory to register, 10 represents pc + 4 to rd
    output logic branch, // b-type instructions
    output logic pcInputA // for jal & b-type instructions, use PC as Input A
);

always_comb begin
    useImmediate = 0;
    readMemory = 0;
    writeMemory = 0;
    writeRegister = 0;
    writebackItem = 2'b0;
    branch = 0;
    pcInputA = 0;
    
    unique case (opcode)
        rTypeInstruction: begin
            writeRegister = 1;
            unique case (funct3)
                3'h0: operationALU = (funct7 == 7'h00) ? addALU : subALU;
                3'h1: operationALU = sllALU;
                3'h2: operationALU = sltALU;
                3'h3: operationALU = sltuALU;
                3'h4: operationALU = xorALU;
                3'h5: operationALU = (funct7 == 7'h00) ? srlALU : sraALU;
                3'h6: operationALU = orALU;
                3'h7: operationALU = andALU;
                
                default: operationALU = noALU;
            endcase
        end
        
        iTypeInstruction: begin
            writeRegister = 1;
            useImmediate = 1;
            unique case (funct3)
                3'h0: operationALU = addALU;
                3'h1: operationALU = sllALU;
                3'h2: operationALU = sltALU;
                3'h3: operationALU = sltuALU;
                3'h4: operationALU = xorALU;
                3'h5: operationALU = (funct7 == 7'h00) ? srlALU : sraALU;
                3'h6: operationALU = orALU;
                3'h7: operationALU = andALU;
                
                default: operationALU = noALU;
            endcase
        end
        
        iTypeInstruction_LOAD: begin
            useImmediate = 1;
            writeRegister = 1;
            readMemory = 1;
            writebackItem = 2'b01;
            operationALU = addALU;
        end
        
        iTypeInstruction_JALR: begin
            useImmediate = 1;
            writeRegister = 1;
            branch = 1;
            operationALU = addALU;
            writebackItem = 2'b10;
        end
        
        sTypeInstruction: begin
            useImmediate = 1;
            writeMemory = 1;
            operationALU = addALU;
        end
            
        bTypeInstruction: begin
            branch = 1;
            unique case (funct3)
                3'h0: operationALU = subALU;
                3'h1: operationALU = subALU;
                3'h4: operationALU = sltALU;
                3'h5: operationALU = sltALU;
                3'h6: operationALU = sltuALU;
                3'h7: operationALU = sltuALU;
                
                default: operationALU = noALU;
            endcase
        end
        
        jTypeInstruction: begin
            branch = 1;
            useImmediate = 1;
            writeRegister = 1;
            operationALU = addALU;
            writebackItem = 2'b10;
            pcInputA = 1;
        end
        
        uTypeInstruction_LUI: begin
            writeRegister = 1;
            useImmediate = 1;
            operationALU = luiALU;
        end
        
        uTypeInstruction_AUIPC: begin
            writeRegister = 1;
            useImmediate = 1;
            pcInputA = 1;
            operationALU = addALU;
        end
        
        default: operationALU = noALU;
    endcase
end

endmodule
