// decode-rename pipeline buffer
module drBuffer (
    input logic clk,
    input logic reset_n, 
    input logic hold_dr,
    

    input logic [31:0] pc_addr_d,
    input logic [31:0] imm_d,

    input logic branch_d,
    input logic mem_read_d,
    input logic [1:0] write_data_d,
    input logic [1:0] alu_op_d,
    input logic mem_write_d,
    input logic alu_src_imm_d,
    input logic reg_write_d,
    input logic alu_src_pc_d,
    input logic jump_d,
    input logic [2:0] load_size_d,

    input logic [4:0] rs1_d,
    input logic [4:0] rs2_d,
    input logic [4:0] rd_d,


    output logic [31:0] pc_addr_r,
    output logic [31:0] imm_r,

    output logic branch_r,
    output logic mem_read_r,
    output logic [1:0] write_data_r,
    output logic [1:0] alu_op_r,
    output logic mem_write_r,
    output logic alu_src_imm_r,
    output logic reg_write_r,
    output logic alu_src_pc_r,
    output logic jump_r,
    output logic [2:0] load_size_r,

    output logic [4:0] rs1_r,
    output logic [4:0] rs2_r,
    output logic [4:0] rd_r
);

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        pc_addr_r <= 32'b0;
        imm_r <= 32'b0;

        branch_r <= 1'b0;
        mem_read_r <= 1'b0;
        write_data_r <= 2'b00;
        alu_op_r <= 2'b00;
        mem_write_r <= 1'b0;
        alu_src_imm_r <= 1'b0;
        reg_write_r <= 1'b0;
        alu_src_pc_r <= 1'b0;
        jump_r <= 1'b0;
        load_size_r <= 3'b0;

        rs1_r <= 5'b0;
        rs2_r <= 5'b0;
        rd_r <= 5'b0;
    end else if (!hold_dr) begin
        pc_addr_r <= pc_addr_d;
        imm_r <= imm_d;

        branch_r <= branch_d;
        mem_read_r <= mem_read_d;
        write_data_r <= write_data_d;
        alu_op_r <= alu_op_d;
        mem_write_r <= mem_write_d;
        alu_src_imm_r <= alu_src_imm_d;
        reg_write_r <= reg_write_d;
        alu_src_pc_r <= alu_src_pc_d;
        jump_r <= jump_d;
        load_size_r <= load_size_d;

        rs1_r <= rs1_d;
        rs2_r <= rs2_d;
        rd_r <= rd_d;
    end
end

endmodule
