module immGen (
    input logic [31:0] insn,
    output logic [31:0] imm
);

always_comb begin
    unique case (insn[6:0])
        7'b0110011: // R-Type Instructions
            imm = 32'b0;

        7'b0010011, 7'b0000011, 7'b1100111: // I-Type Instructions
            imm = {{20{insn[31]}}, insn[31:20]};

        7'b0100011: // S-Type Instructions
            imm = {{20{insn[31]}}, insn[31:25], insn[11:7]};

        7'b1100011: // B-Type Instructions
            imm = {{19{insn[31]}}, insn[31], insn[7], insn[30:25], insn[11:8], 1'b0};

        7'b0110111, 7'b0010111: // U-Type Instructions
            imm = {insn[31:12], 12'b0};

        7'b1101111: // J-Type Instructions
            imm = {{11{insn[31]}}, insn[31], insn[19:12], insn[20], insn[30:21], 1'b0};

        default: imm = 32'b0;
    endcase
end

endmodule