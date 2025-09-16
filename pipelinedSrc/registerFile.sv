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

always_comb begin
    if (r1Address == 0) begin
        r1Data = 0;
    end else if (writeRegister && r1Address == writeAddress) begin
        r1Data = writeData;
    end else begin
        r1Data = registers[r1Address];
    end
    
    if (r2Address == 0) begin
        r2Data = 0;
    end else if (writeRegister && r2Address == writeAddress) begin
        r2Data = writeData;
    end else begin
        r2Data = registers[r2Address];
    end
end

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
