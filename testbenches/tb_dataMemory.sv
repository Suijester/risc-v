`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 07:17:09 PM
// Design Name: 
// Module Name: tb_dataMemory
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

module tb_dataMemory;

logic clk;
logic [31:0] address;
logic [31:0] readData;

logic readMemory;
logic [2:0] funct3;
logic writeMemory;
logic [31:0] writeData;

logic allAssertsPassed;

dataMemory DUT (
    .clk(clk),
    .address(address),
    .readData(readData),
    .readMemory(readMemory),
    .funct3(funct3),
    .writeMemory(writeMemory),
    .writeData(writeData)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    // read test
    logic allAssertsPassed = 1;
    DUT.dataMem[4] = 32'hAABBCCDD;
    address = 17; // second lowest byte of dataMem[4]
    funct3 = 0; // LB
    readMemory = 1;
    #1;
    if (readData != 32'hFFFFFFCC) begin // load and write are signed, so we have to sign extend
        allAssertsPassed = 0;
        $error("readData does not match 8'hCC, readData = 8'h%0h", readData);
    end
    
    #1;
    address = 18;
    funct3 = 3'h1; // upper half of dataMem[4]
    #1;
    if (readData != 32'hFFFFAABB) begin
        allAssertsPassed = 0;
        $error("readData does not match 16'hAABB, readData = 16'h%0h", readData);
    end
    
    #1;
    address = 19;
    funct3 = 3'h2; // entire word
    #1;
    if (readData != 32'hAABBCCDD) begin
        allAssertsPassed = 0;
        $error("readData does not match 32'hAABBCCDD, readData = 32'h%0h", readData);
    end
    
    // write test
    #1; readMemory = 0; #1;
    writeData = 32'hABCDABCD; // should only take lowest byte
    address = 3;
    funct3 = 3'h0; // store byte
    writeMemory = 1;
    @(posedge clk); #1;
    writeMemory = 0;
    readMemory = 1;
    #1;
    
    if (readData != 32'hFFFFFFCD) begin
        allAssertsPassed = 0;
        $error("readData does not match 8'hCD, readData = 8'h%0h", readData);
    end
    
    #1; readMemory = 0; #1;
    writeData = 32'hAAAA; // load half
    address = 6;
    funct3 = 3'h1;
    writeMemory = 1;
    @(posedge clk); #1;
    writeMemory = 0;
    readMemory = 1;
    #1;
    
    if (readData != 32'hFFFFAAAA) begin
        allAssertsPassed = 0;
        $error("readData does not match 16'hAAAA, readData = 16'h%0h", readData);
    end
    
    #1; readMemory = 0; #1;
    writeData = 32'h10101010;
    address = 8;
    funct3 = 3'h2; // load entire word
    writeMemory = 1;
    @(posedge clk); #1;
    writeMemory = 0;
    readMemory = 1;
    #1;
    
    if (readData != 32'h10101010) begin
        allAssertsPassed = 0;
        $error("readData does not match 32'h10101010, readData = 32'h%0h", readData);
    end
    
    #5;
    
    if (allAssertsPassed) begin
        $display("All asserts passed!");
    end
    
end

endmodule
