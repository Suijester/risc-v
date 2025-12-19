`ifndef OPTYPES_H
`define OPTYPES_H

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

    noALU = 4'b1111
} ALU_operation_t;

`endif
