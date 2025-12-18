module controlUnit (
    input logic [31:0] insn,

    output logic branch,            // 1 if it's a branch-type instruction
    output logic mem_read,          // 1 if we read from memory
    output logic [1:0] write_data,  // 2 if we write PC + 4, 1 if we write mem data, 0 if ALU result
    output logic [1:0] alu_op,      // 0 if addition, 1 if subtraction, 2 if we have to determine
    output logic mem_write,         // 1 is we write to memory system 
    output logic alu_src_imm,       // 1 if we use immediate, 0 if rs2
    output logic reg_write,         // 1 if we writeback to registers
    output logic alu_src_pc,        // 1 if we use PC, 0 if rs1
    output logic jump               // 1 if JAL or JALR (guaranteed jump, OR with branch mux)
);

// combinational alias for opcode
logic [6:0] opcode;
assign opcode = insn[6:0];

always_comb begin
    // set defaults to prevent latch
    branch = 0;
    mem_read = 0;
    write_data = 2'b00;
    alu_op = 2'b10;
    mem_write = 0;
    alu_src_imm = 0;
    reg_write = 0;
    alu_src_pc = 0;
    jump = 0;

    unique case (opcode)
        7'b0110011: begin // R-Type Instruction
            reg_write = 1;
        end

        7'b0010011: begin // I-Type Instruction
            alu_src_imm = 1;
            reg_write = 1;
        end

        7'b0000011: begin // I-Type Load Instruction
            write_data = 2'b01;
            alu_op = 2'b00;
            alu_src_imm = 1;
            reg_write = 1;
            mem_read = 1;
        end

        7'b1100111: begin // I-Type JALR
            write_data = 2'b10;
            alu_op = 2'b00;
            alu_src_imm = 1;
            reg_write = 1;
            jump = 1;
        end

        7'b0100011: begin // S-Type Instruction
            alu_op = 2'b00;
            alu_src_imm = 1;
            mem_write = 1;
        end

        7'b1100011: begin // B-Type Instruction
            branch = 1;
            alu_op = 2'b01;
        end

        7'b1101111: begin // J-Type Instruction
            write_data = 2'b10;
            alu_op = 2'b00;
            alu_src_imm = 1;
            reg_write = 1;
            alu_src_pc = 1;
            jump = 1;
        end

        7'b0110111: begin // U-Type LUI Instruction
            reg_write = 1;
            alu_src_imm = 1;
        end

        7'b0010111: begin // U-Type AUIPC Instruction
            reg_write = 1;
            alu_src_imm = 1;
            alu_src_pc = 1;
        end

        default: ;
    endcase
end

endmodule