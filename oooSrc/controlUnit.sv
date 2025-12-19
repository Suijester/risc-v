module controlUnit (
    /* verilator lint_off UNUSEDSIGNAL */
    input logic [31:0] insn,
    /* verilator lint_on UNUSEDSIGNAL */

    output logic branch,            // 1 if it's a branch-type instruction
    output logic mem_read,          // 1 if we read from memory
    output logic [1:0] write_data,  // 2 if we write PC + 4, 1 if we write mem data, 0 if ALU result
    output logic [1:0] alu_op,      // 0 if addition, 1 if subtraction, 2 if we have to determine
    output logic mem_write,         // 1 is we write to memory system 
    output logic alu_src_imm,       // 1 if we use immediate, 0 if rs2
    output logic reg_write,         // 1 if we writeback to registers
    output logic alu_src_pc,        // 1 if we use PC, 0 if rs1
    output logic jump,              // 1 if JAL or JALR (guaranteed jump, OR with branch mux)
    output logic [2:0] load_size,   // upper bit denotes signed or unsigned (1/0), 00 is byte, 01 is half, 10 is word

    output logic [4:0] rs1,
    output logic [4:0] rs2,
    output logic [4:0] rd
);

// combinational alias for opcode
logic [6:0] opcode;
assign opcode = insn[6:0];

// register outputs
assign rd = insn[11:7];
assign rs1 = insn[19:15];
assign rs2 = insn[24:20];

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
    load_size = 3'b000;

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

            unique case (insn[14:12])
                3'h0: load_size = 3'b100;
                3'h1: load_size = 3'b101;
                3'h2: load_size = 3'b110;
                3'h4: load_size = 3'b000;
                3'h5: load_size = 3'b001;
                default: ;
            endcase
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
            alu_op = 2'b00;
        end

        default: ;
    endcase
end

endmodule
