module instructionMemory #(
    parameter CORE_WIDTH = 2,
    parameter MEM_SIZE = 128 // instr count by default
) (
    input logic [31:0] pc_addr,
    output logic [(CORE_WIDTH * 32)-1:0] instruction_blk
);

logic [31:0] instr_mem [0:MEM_SIZE - 1] = '{default: 32'h00000013};

always_comb begin
    instruction_blk = '0;
    for (int i = 0; i < CORE_WIDTH; i++) begin
        // check bounds; do not perform accesses beyond memory size (i.e., oob accesses)
        if (pc_addr[31:2] + i < MEM_SIZE) begin
            instruction_blk[i * 32 +: 32] = instr_mem[pc_addr[31:2] + i];
        end else begin
            instruction_blk[i * 32 +: 32] = 32'h00000013; // addi x0, x0, 0 (NOP)
        end
    end
end

endmodule