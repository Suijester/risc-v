// decode-rename pipeline buffer
module drBuffer # (
    parameter CORE_WIDTH = 2
) (
    input logic clk,
    input logic reset_n, 
    input logic hold_dr,

    input logic [31:0] pc_addr_d,
    input logic [31:0] imm_d,

    output logic [31:0] pc_addr_r,
    output logic [31:0] imm_r
);

endmodule