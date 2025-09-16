`timescale 1ns / 1ps
module l1Cache (
    input logic clk,
    input logic reset,
    input logic [31:0] pcAddress,

    // on cache miss, write to L1 Cache
    input logic writeCache,
    input logic [3:0] writeIndex,
    input logic [24:0] writeTag,
    input logic [63:0] writeData,

    output logic cacheHit,
    output logic [31:0] instructionCode
);

logic [63:0] cacheMemory [0:15]; // cache line of 8 bytes, with 16 blocks
logic [24:0] cacheTagStorage [0:15]; // stores cache tags
logic [15:0] cacheBitmap;

logic [2:0] cacheOffset; // clog2(cache line in bytes) = 3, need 3 bits to represent 8 bytes in cacheMemory
logic [3:0] cacheIndex; // clog2(cache blocks) = 4, need 4 bits to represent 16 blocks
logic [24:0] cacheTag; // remainder of bits in address can be tag bits

assign cacheIndex = pcAddress[6:3];
assign cacheTag = pcAddress[31:7];

assign cacheHit = cacheBitmap[cacheIndex] & (cacheTagStorage[cacheIndex] == cacheTag);
assign instructionCode = (pcAddress[2]) ?  cacheMemory[cacheIndex][31:0] : cacheMemory[cacheIndex][63:32];

always_ff @(posedge clk or negedge reset) begin
    if (!reset) begin
        cacheBitmap <= 0;
    end else if (writeCache) begin
        cacheMemory[writeIndex] <= writeData;
        cacheTagStorage[writeIndex] <= writeTag;
        cacheBitmap[writeIndex] <= 1;
    end
end

endmodule