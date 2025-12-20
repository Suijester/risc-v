// wrapper module to simplify hardware replication/synthesis for OOO
module decodeTop (
    input logic [31:0] insn,

    output logic [31:0] imm,
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

immGen immGen_m (
    .insn(insn),
    .imm(imm)
);

controlUnit controlUnit_m (
    .insn(insn),

    .branch(branch),
    .mem_read(mem_read),
    .write_data(write_data),
    .alu_op(alu_op),
    .mem_write(mem_write),
    .alu_src_imm(alu_src_imm),
    .reg_write(reg_write),
    .alu_src_pc(alu_src_pc),
    .jump(jump),
    .load_size(load_size),

    .rs1(rs1),
    .rs2(rs2),
    .rd(rd)
);

endmodule
