`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 03:42:25 PM
// Design Name: 
// Module Name: ALU
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

module ALU(
    input ALU_operation_t operation,
    input logic [31:0] A,
    input logic [31:0] B,
    
    output logic [31:0] result,
    output logic zero
);

assign zero = (result == 0);

always_comb begin
    unique case (operation)
        addALU: result = A + B;
        subALU: result = A - B;
        xorALU: result = A ^ B;
        orALU: result = A | B;
        andALU: result = A & B;
        sllALU: result = A << B[4:0];
        srlALU: result = A >> B[4:0];
        sraALU: result = $signed(A) >>> B[4:0];
        sltALU: result = ($signed(A) < $signed(B)) ? 1 : 0;
        sltuALU: result = (A < B) ? 1 : 0;
        luiALU: result = B;
        noALU: result = 32'b0;
        
        default: result = 32'b0;
    endcase
end

endmodule
