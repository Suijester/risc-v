`include "opTypes.svh"

module aluControl (
    input logic [31:0] insn,
    input logic [1:0] alu_op,

    output ALU_operation_t alu_operation
);

logic [6:0] opcode;
assign opcode = insn[6:0];

logic [2:0] funct3;
assign funct3 = insn[14:12];

always_comb begin
    alu_operation = noALU;
    if (alu_op != 2'b10) begin
        alu_operation = {2'b0, alu_op};
    end else begin
        unique case (opcode)
            7'b0110011: begin // R-Type Instruction
                unique case (funct3)
                    3'h0: alu_operation = (insn[31:25] == 7'h00) ? addALU : subALU;
                    3'h4: alu_operation = xorALU;
                    3'h6: alu_operation = orALU;
                    3'h7: alu_operation = andALU;
                    3'h1: alu_operation = sllALU;
                    3'h5: alu_operation = (insn[31:25] == 7'h00) ? srlALU : sraALU;
                    3'h2: alu_operation = sltALU;
                    3'h3: alu_operation = sltuALU;
                endcase
            end

            7'b0010011: begin // I-Type Instruction
                unique case (funct3)
                    3'h0: alu_operation = addALU;
                    3'h4: alu_operation = xorALU;
                    3'h6: alu_operation = orALU;
                    3'h7: alu_operation = andALU;
                    3'h1: alu_operation = sllALU;
                    3'h5: alu_operation = (insn[31:25] == 7'h00) ? srlALU : sraALU;
                    3'h2: alu_operation = sltALU;
                    3'h3: alu_operation = sltuALU;
                endcase
            end

            7'b0000011: begin // I-Type Load Instruction
                alu_operation = addALU; // should automatically be add via alu_op control signal
            end

            7'b1100111: begin // I-Type JALR
                alu_operation = addALU; // should automatically be add via alu_op control signal
            end

            7'b0100011: begin // S-Type Instruction
                alu_operation = addALU; // should automatically be add via alu_op control signal
            end

            7'b1100011: begin // B-Type Instruction
                alu_operation = subALU; // should automatically be sub via alu_op control signal
            end

            7'b1101111: begin // J-Type Instruction
                alu_operation = addALU; // should automatically be add via alu_op control signal
            end

            7'b0110111: begin // U-Type LUI Instruction
                alu_operation = luiALU; // special op that forwards imm for simplicity
            end

            7'b0010111: begin // U-Type AUIPC Instruction
                alu_operation = addALU; // should automatically be add via alu_op control signal
            end

            default: ;
        endcase
    end
end

endmodule
