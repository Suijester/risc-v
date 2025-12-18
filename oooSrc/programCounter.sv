module programCounter #(
    parameter CORE_WIDTH = 2,
    parameter INSN_BYTES = 4
) (
    input logic clk,
    input logic reset_n,

    input logic hold_pc,
    input logic redirect_enable,
    input logic [31:0] redirect_addr,

    output logic [31:0] next_pc
);

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        next_pc <= 32'b0;
    end else if (redirect_enable) begin
        next_pc <= redirect_addr;
    end else if (!hold_pc) begin
        next_pc <= next_pc + (CORE_WIDTH * INSN_BYTES);
    end
end

endmodule
