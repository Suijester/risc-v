module tb_instrMem;

localparam CORE_WIDTH = 2;
localparam MEM_SIZE = 128;

logic [31:0] pc_addr;
logic [(CORE_WIDTH * 32)-1:0] instruction_blk;

instructionMemory # (
    .CORE_WIDTH(CORE_WIDTH),
    .MEM_SIZE(MEM_SIZE)
) DUT (
    .pc_addr(pc_addr),
    .instruction_blk(instruction_blk)
);

function automatic logic [(CORE_WIDTH * 32)-1:0] expected_instr_blk(input logic [31:0] pc_address);
    int base = {2'b0, pc_address[31:2]};
    assert(pc_address[1:0] == 2'b00)
        else $fatal(1, "Bad byte alignment; pc_addr[1:0] != 2'b00.");

    for (int i = 0; i < CORE_WIDTH; i++) begin
        if (base + i < MEM_SIZE) begin
            expected_instr_blk[i * 32 +: 32] = DUT.instr_mem[base + i];
        end else begin
            expected_instr_blk[i * 32 +: 32] = 32'h00000013; // expect a NOP
        end
    end
endfunction

initial begin
    DUT.instr_mem[0] = 32'h00000000;
    DUT.instr_mem[1] = 32'h11111111;
    DUT.instr_mem[2] = 32'h22222222;
    DUT.instr_mem[3] = 32'h33333333;
    DUT.instr_mem[4] = 32'h44444444;
    DUT.instr_mem[5] = 32'h55555555;
    DUT.instr_mem[6] = 32'h66666666;
    DUT.instr_mem[7] = 32'h77777777;
    DUT.instr_mem[8] = 32'h88888888;
    DUT.instr_mem[9] = 32'h99999999;
    DUT.instr_mem[10] = 32'hAAAAAAAA;
    DUT.instr_mem[11] = 32'hBBBBBBBB;
    DUT.instr_mem[12] = 32'hCCCCCCCC;
    DUT.instr_mem[13] = 32'hDDDDDDDD;
    DUT.instr_mem[14] = 32'hEEEEEEEE;
    DUT.instr_mem[15] = 32'hFFFFFFFF;

    DUT.instr_mem[125] = 32'hDEADBEEF;
    DUT.instr_mem[126] = 32'h01010101;
    DUT.instr_mem[127] = 32'hABABABAB;

    // check basic case
    pc_addr = 32'h00000004;
    #1;

    if (CORE_WIDTH == 2) begin
        assert(instruction_blk == {DUT.instr_mem[2], DUT.instr_mem[1]});
            else $fatal(1, "Instruction block didn't meet base case expectation (core width = 2)");
    end

    assert(instruction_blk === expected_instr_blk(pc_addr))
        else $fatal(1, "Instruction block did not meet expectation!");

    // check edge cases
    pc_addr = (128 << 2);
    #1;
    assert(instruction_blk === expected_instr_blk(pc_addr))
        else $fatal(1, "Edge case pc_addr = 128 block did not meet expectation!");

    pc_addr = (127 << 2);
    #1;
    assert(instruction_blk === expected_instr_blk(pc_addr))
        else $fatal(1, "Edge case pc_addr = 127 block did not meet expectation!");

    pc_addr = (126 << 2);
    #1;
    assert(instruction_blk === expected_instr_blk(pc_addr))
        else $fatal(1, "Edge case pc_addr = 126 block did not meet expectation!");

    pc_addr = (125 << 2);
    #1;
    assert(instruction_blk === expected_instr_blk(pc_addr))
        else $fatal(1, "Edge case pc_addr = 125 block did not meet expectation!");

    // random tests
    repeat (50) begin
        pc_addr = ($urandom_range(0, 127) << 2);
        #1;
        assert(instruction_blk === expected_instr_blk(pc_addr))
            else $fatal(1, "Instruction block did not meet expectation!");
    end

    $display("Success! Instruction Memory Testbench passed.");
    $finish;
end

endmodule
