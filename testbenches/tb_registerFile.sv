`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 03:08:16 PM
// Design Name: 
// Module Name: tb_registerFile
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


module tb_registerFile;

logic clk;
logic reset;
    
logic [4:0] r1Address;
logic [4:0] r2Address;
logic [31:0] r1Data;
logic [31:0] r2Data;

logic writeRegister;
logic [4:0] writeAddress;
logic [31:0] writeData;

registerFile DUT (
    .clk(clk),
    .reset(reset),
    .r1Address(r1Address),
    .r2Address(r2Address),
    .r1Data(r1Data),
    .r2Data(r2Data),
    .writeRegister(writeRegister),
    .writeAddress(writeAddress),
    .writeData(writeData)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 0;
    r1Address = 0;
    r2Address = 0;
    writeRegister = 0;
    writeAddress = 0;
    writeData = 0;
    #10;
    
    reset = 1; 
    $display("Registers reset."); #10;
    
    // write 0xFF to address 5
    writeAddress = 5;
    writeData = 32'hFF;
    writeRegister = 1;
    @(posedge clk); #3;
    writeRegister = 0;
    
    // check if address 5 now contains the data
    r1Address = 5; #1;
    if (r1Data == 32'hFF) begin
        $display("Passed | Data = %0h", r1Data);
    end else begin
        $error("Failed | Expected = 0xFF | Actual = %0h", r1Data);
    end
    #5;
    
    // write 0x88888888 to address 10
    writeAddress = 10;
    writeData = 32'h88888888;
    writeRegister = 1;
    @(posedge clk); #3;
    writeRegister = 0; 
    
    // check dual port read
    r1Address = 5; r2Address = 10; #1;
    if (r1Data == 32'hFF && r2Data == 32'h88888888) begin
        $display("Passed | R1 Data = %0h | R2 Data = %0h", r1Data, r2Data);
    end else begin
        $error("Failed | Expected R1 = 0xFF | Expected R2 = 0x88888888 | Actual R1 = %0h | Actual R2 = %0h", r1Data, r2Data);
    end
    #5;
    
    // check writing to 0 is impossible
    writeAddress = 0;
    writeData = 32'h11111111;
    writeRegister = 1;
    @(posedge clk); #3;
    writeRegister = 0; 
    
    r1Address = 0; #1;
    if (r1Data == 32'h0) begin
        $display("Passed, x0 was not overwritten");
    end else begin
        $error("Failed, x0 Overwritten | Expected = 0x00000000 | Actual = %0h", r1Data);
    end
    #5;
end

endmodule
