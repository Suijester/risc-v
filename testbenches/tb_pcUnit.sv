`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/07/2025 06:52:36 PM
// Design Name: 
// Module Name: tb_pcUnit
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

module tb_pcUnit;

logic clk;
logic reset;

logic takeBranch;
logic [31:0] pcAddress;
logic [31:0] branchAddress;

programCounter DUT (
    .clk(clk),
    .reset(reset),
    .takeBranch(takeBranch),
    .branchAddress(branchAddress),
    .pcAddress(pcAddress)
);

initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

initial begin
    reset = 0;
    takeBranch = 0;
    branchAddress = 32'b0;
    #10;
    
    reset = 1;
    $display("PC Unit reset. pcAddress = %0h", pcAddress); #10;
    
    branchAddress = 32'h5;
    takeBranch = 1;
    @(posedge clk); #1;
    takeBranch = 0;
    
    if (pcAddress == 32'h5) begin
        $display("Correct PC Address, pcAddress = 0x5");
    end else begin
        $error("Incorrect PC Address | Expected = 0x5 | Actual = %0h", pcAddress);
    end
    
    @(posedge clk); #1;
    
    if (pcAddress == 32'h9) begin
        $display("Correct PC Address, pcAddress = 0x9");
    end else begin
        $error("Incorrect PC Address | Expected = 0x9 | Actual = %0h", pcAddress);
    end
    
    takeBranch = 0;
    branchAddress = 32'h12;
    
    @(posedge clk);
    if (pcAddress == 32'h12) begin
        $error("Incorrect PC Address | Received 0x12, branchAddress was accepted");
    end else begin
        $display("Correct: pcAddress = 0x%0h", pcAddress); // should be 0xD
    end
end
endmodule
