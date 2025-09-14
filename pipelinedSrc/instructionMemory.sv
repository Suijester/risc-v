`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 02:07:22 PM
// Design Name: 
// Module Name: instructionMemory
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

module instructionMemory #(
    parameter memorySize = 64
)(
    input logic clk,
    input logic reset,
    input logic [31:0] passedPC, // from cache controller
    input logic instructionRequest,

    output logic [31:0] instruction,
    output logic [63:0] cacheData,
    output logic receivedInstruction
);

logic [31:0] savedPCAddress;

typedef enum logic [0:0] {
    receivingState = 1'b0,
    passingState = 1'b1
} memoryState;

logic [31:0] instructionMem [0:memorySize - 1];
memoryState currentState;
memoryState nextState;

always_ff @(posedge clk or negedge reset) begin
    currentState <= (!reset) ? receivingState : nextState;
    savedPCAddress <= (currentState == receivingState) ? passedPC : savedPCAddress;
end

always_comb begin
    nextState = currentState;
    instruction = 32'b0;
    cacheData = 64'b0;
    receivedInstruction = 0;

    unique case (currentState) begin
        receivingState: begin
            nextState = instructionRequest ? passingState : receivingState;
        end

        passingState: begin
            receivedInstruction = 1;
            cacheData = {instructionMem[savedPCAddress[31:3] << 1], instructionMem[(savedPCAddress[31:3] << 1) + 1]};
            instruction = instructionMem[savedPCAddress[31:2]];
            nextState = receivingState;
        end
    endcase

end

initial begin
    instructionMem[0] = 32'h00500113;  // addi x2, x0, 5
    instructionMem[1] = 32'h00300193;  // addi x3, x0, 3
    instructionMem[2] = 32'h003100b3;  // add x1, x2, x3
    instructionMem[3] = 32'h40310133;  // sub x2, x2, x3
    instructionMem[4] = 32'h00108093;  // addi x1, x1, 1
    instructionMem[5] = 32'hfe510ee3;  // bne x2, x0, -4
    instructionMem[6] = 32'h005002b3;  // add x5, x1, x0
end

endmodule