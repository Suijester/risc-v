`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/06/2025 03:02:13 PM
// Design Name: 
// Module Name: dataMemory
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

module dataMemory #(
    parameter memorySize = 256
)(
    input logic clk,
    input logic [31:0] address, // read/write address (single port memory), should be $clog2(address)
    output logic [31:0] readData,
    
    input logic readMemory,
    input logic [2:0] funct3,
    input logic writeMemory,
    input logic [31:0] writeData
);

logic [31:0] dataMem [0:memorySize - 1];

always_comb begin
    if (readMemory) begin // load-type instruction
        unique case (funct3)
            3'h0: begin // LB (signed)
                unique case (address[1:0]) // check byte offset
                    2'b00: readData = {{24{dataMem[address[31:2]][7]}}, dataMem[address[31:2]][7:0]}; // no offset, take lowest byte
                    2'b01: readData = {{24{dataMem[address[31:2]][15]}}, dataMem[address[31:2]][15:8]}; // one byte offset
                    2'b10: readData = {{24{dataMem[address[31:2]][23]}}, dataMem[address[31:2]][23:16]}; // two bytes offset
                    2'b11: readData = {{24{dataMem[address[31:2]][31]}}, dataMem[address[31:2]][31:24]}; // three bytes offset
                endcase
            end
            
            3'h1: begin // LH (signed)
                unique case (address[1]) // check half offset
                    1'b0: readData = {{16{dataMem[address[31:2]][15]}}, dataMem[address[31:2]][15:0]}; // no byte offset
                    1'b1: readData = {{16{dataMem[address[31:2]][31]}}, dataMem[address[31:2]][31:16]}; // two byte offset, take upper half
                endcase
            end
            
            3'h2: readData = dataMem[address[31:2]]; // LW, just take whole word
            
            3'h4: begin // LB (unsigned)
                unique case (address[1:0]) // check byte offset
                    2'b00: readData = {24'b0, dataMem[address[31:2]][7:0]}; // no offset, take lowest byte
                    2'b01: readData = {24'b0, dataMem[address[31:2]][15:8]}; // one byte offset
                    2'b10: readData = {24'b0, dataMem[address[31:2]][23:16]}; // two bytes offset
                    2'b11: readData = {24'b0, dataMem[address[31:2]][31:24]}; // three bytes offset
                endcase
            end
            
            3'h5: begin // LH (unsigned)
                unique case (address[1]) // check half offset
                    1'b0: readData = {16'b0, dataMem[address[31:2]][15:0]}; // no byte offset
                    1'b1: readData = {16'b0, dataMem[address[31:2]][31:16]}; // two byte offset, take upper half
                endcase
            end
            
            default: readData = 32'b0;
        endcase
    end
end


always_ff @(posedge clk) begin
    if (writeMemory) begin
        unique case (funct3)
            3'h0: begin // SB
                unique case (address[1:0]) // check byte offset
                    2'b00: dataMem[address[31:2]][7:0] <= writeData[7:0];
                    2'b01: dataMem[address[31:2]][15:8] <= writeData[7:0]; // one byte offset
                    2'b10: dataMem[address[31:2]][23:16] <= writeData[7:0]; // two bytes offset
                    2'b11: dataMem[address[31:2]][31:24] <= writeData[7:0]; // three bytes offset
                endcase
            end
            3'h1: begin // SH
                unique case (address[1])
                    1'b0: dataMem[address[31:2]][15:0] <= writeData[15:0];
                    1'b1: dataMem[address[31:2]][31:16] <= writeData[15:0];
                endcase
            end
            3'h2: dataMem[address[31:2]][31:0] <= writeData[31:0]; // SW
        endcase
    end
end

endmodule