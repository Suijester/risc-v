`ifndef ENUMTYPES_H
`define ENUMTYPES_H

typedef enum logic [3:0] {
    addALU = 4'b0000,
    subALU = 4'b0001,
    xorALU = 4'b0010,
    orALU = 4'b0011,
    andALU = 4'b0100,
    sllALU = 4'b0101,
    srlALU = 4'b0110,
    sraALU = 4'b0111,
    sltALU = 4'b1000,
    sltuALU = 4'b1001,
    luiALU = 4'b1010,
    noALU = 4'b1011
} ALU_operation_t;


typedef enum logic [6:0] {
    rTypeInstruction = 7'b0110011,
    iTypeInstruction = 7'b0010011,
    iTypeInstruction_LOAD = 7'b0000011,
    iTypeInstruction_JALR = 7'b1100111,
    sTypeInstruction = 7'b0100011,
    bTypeInstruction = 7'b1100011,
    jTypeInstruction = 7'b1101111,
    uTypeInstruction_LUI = 7'b0110111,
    uTypeInstruction_AUIPC = 7'b0010111,
    emptyType = 0
} opcode_t;

`endif