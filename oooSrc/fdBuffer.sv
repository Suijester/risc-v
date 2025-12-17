// fetch-decode pipeline buffer
module fdBuffer # (
    parameter CORE_WIDTH = 2
) (
    input logic clk,
    input logic reset_n,
    input logic hold_fd,

    input logic [31:0] pc_addr_f,
    input logic [(CORE_WIDTH * 32) - 1:0] instr_blk_f,

    output logic [31:0] pc_addr_d,
    output logic [(CORE_WIDTH * 32) - 1:0] instr_blk_d
);

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pc_addr_d <= '0;
        instr_blk_d <= {CORE_WIDTH{32'h00000013}};
    end else if (!hold_fd) begin
        pc_addr_d <= pc_addr_f;
        instr_blk_d <= instr_blk_f;
    end
end

endmodule