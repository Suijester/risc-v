`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 09/09/2025 02:29:55 PM
// Design Name: 
// Module Name: hazardModule
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

module hazardModule(
    input logic [4:0] r1Address_ID,
    input logic [4:0] r2Address_ID,
    
    input logic [4:0] r1Address_EX,
    input logic [4:0] r2Address_EX,
    
    input logic [4:0] rdAddress_EX,
    input logic readMemory_EX, // if load-type, need to wait an extra cycle
    input logic writeRegister_EX, // need to wait till this instruction is completed
    
    input logic [4:0] rdAddress_MEM,
    input logic writeRegister_MEM,
    input logic takeBranch_MEM, // need to check if a branch was taken, and if so, then flush id, if, ex
    
    input logic [4:0] rdAddress_WB,
    input logic writeRegister_WB,
    
    output logic [1:0] forwardItemA_EX, // 00 means keep r1Data, 01 means take data from MEM, 10 means take writeData from WB
    output logic [1:0] forwardItemB_EX,
    output logic pcEnable, // active-low when we want to stop taking instructions
    output logic ifidEnable, // active-low, so we can freeze what's inside of ID without overwriting it (forwarding hazard)
    output logic ifidClear, // active-high, when we want to empty out ifid if we take a branch
    output logic idexClear, // active-high, when we want to empty out idex if we take a branch or wait for forwarding data
    output logic exmemClear // active-high, empties out exmem if we take a branch
);

// Load Hazard & Branch Hazard
logic loadHazard; // hazard caused by having to wait an extra cycle to gain the result of load from MEM
assign loadHazard = (readMemory_EX && (rdAddress_EX != 0) && ((r1Address_ID == rdAddress_EX) || (r2Address_ID == rdAddress_EX)));

assign pcEnable = ~loadHazard;
assign ifidEnable = ~loadHazard;
assign idexClear = (loadHazard || takeBranch_MEM);
assign ifidClear = takeBranch_MEM;
assign exmemClear = takeBranch_MEM;

// Forwarding Data Hazard
always_comb begin
    forwardItemA_EX = 0;
    forwardItemB_EX = 0;
    
    // input A forwarding
    if (writeRegister_MEM && (rdAddress_MEM != 0) && (r1Address_EX == rdAddress_MEM)) begin
        forwardItemA_EX = 2'b01;
    end else if (writeRegister_WB && (rdAddress_WB != 0) && (r1Address_EX == rdAddress_WB)) begin
        forwardItemA_EX = 2'b10;
    end
    
    if (writeRegister_MEM && (rdAddress_MEM != 0) && (r2Address_EX == rdAddress_MEM)) begin
        forwardItemB_EX = 2'b01;
    end else if (writeRegister_WB && (rdAddress_WB != 0) && (r2Address_EX == rdAddress_WB)) begin
        forwardItemB_EX = 2'b10;
    end
end

endmodule
