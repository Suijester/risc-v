module registerFile (
    input logic clk,
    input logic reset_n,

    input logic [4:0] rs1,
    input logic [4:0] rs2,
    output logic [31:0] rs1_data,
    output logic [31:0] rs2_data,

    input logic reg_write,
    input logic [4:0] rd,
    input logic [31:0] reg_write_data
);

logic [31:0] register_mem [0:31];

assign rs1_data = (rs1 == 0) ? 32'h0 : register_mem[rs1];
assign rs2_data = (rs2 == 0) ? 32'h0 : register_mem[rs2];

always_ff @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        for (int i = 0; i < 32; i++) begin
            register_mem[i] <= 32'b0;
        end
    end else if (reg_write && rd != 5'b0) begin
        register_mem[rd] <= reg_write_data;
    end
end

endmodule
