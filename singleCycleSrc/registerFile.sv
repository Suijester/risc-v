`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 04:24:55 PM
// Design Name: 
// Module Name: registerFile
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

module registerFile(
    input logic clk,
    input logic reset,
    
    input logic [4:0] r1Address,
    input logic [4:0] r2Address,
    output logic [31:0] r1Data,
    output logic [31:0] r2Data,
    
    input logic writeRegister,
    input logic [4:0] writeAddress,
    input logic [31:0] writeData
);

logic [31:0] registers [0:31];

assign r1Data = (r1Address == 0) ? 32'b0 : registers[r1Address];
assign r2Data = (r2Address == 0) ? 32'b0 : registers[r2Address];

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        for (int i = 0; i < 32; i++) begin
            registers[i] <= 32'b0;
        end
    end else if (writeRegister && writeAddress != 5'b0) begin
        registers[writeAddress] <= writeData;
    end
end

endmodule
