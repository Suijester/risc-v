module tb_programCounter;

logic clk;
logic reset_n;

logic hold_pc;
logic redirect_enable;
logic [31:0] redirect_addr;

logic [31:0] next_pc;

localparam CORE_WIDTH = 2;
localparam INSN_BYTES = 4;
localparam TOTAL_INSN_BYTES = CORE_WIDTH * INSN_BYTES;
localparam CLK_HALF = 5;

programCounter # (
    .CORE_WIDTH(CORE_WIDTH),
    .INSN_BYTES(INSN_BYTES)
) DUT (
    .clk(clk),
    .reset_n(reset_n),
    .hold_pc(hold_pc),
    .redirect_enable(redirect_enable),
    .redirect_addr(redirect_addr),
    .next_pc(next_pc)
);

// initialize clock
initial begin
    clk = 0;
    forever #CLK_HALF clk = ~clk;
end

// reset task
task automatic reset_pc();
    hold_pc = 1'b0;
    redirect_enable = 1'b0;
    redirect_addr = 32'b0;

    reset_n = 1'b0;
    repeat (2) @(posedge clk);
    reset_n = 1'b1;

    #1; // ensure no race happens
    // next pc must be current (0x0) + CORE_WIDTH * INSN_BYTES
    assert(next_pc === TOTAL_INSN_BYTES)
        else $fatal(1, "reset_pc failed: nextPC = 32'h%h", next_pc);
endtask

task automatic tick_pc(input logic [31:0] exp_pc);
    @(posedge clk);
    #1; // ensure no race happens
    assert(next_pc === exp_pc)
        else $fatal(1, "tick_pc failed: next_pc = 32'h%h, exp_pc = 32'h%h", next_pc, exp_pc);
endtask

task automatic change_inputs(input logic hold, input logic redir_en, input logic [31:0] redir_addr);
    @(negedge clk);
    hold_pc = hold;
    redirect_enable = redir_en;
    redirect_addr = redir_addr;
endtask

function automatic logic [31:0] expected_change(input logic [31:0] curr_pc,
    input logic hold, 
    input logic redir_en, 
    input logic [31:0] redir_addr
);
    if (redir_en) expected_change = redir_addr;
    else if (hold) expected_change = curr_pc;
    else expected_change = curr_pc + TOTAL_INSN_BYTES;
endfunction


// clocked reset for synchronous disables (won't compile otherwise)
logic reset_n_clocked;

always_ff @(posedge clk or negedge reset_n) begin
    reset_n_clocked <= reset_n;
end

property p_holds_pc;
    @(posedge clk) disable iff (!reset_n_clocked)
        (hold_pc && !redirect_enable) |=> (next_pc === $past(next_pc));
endproperty

assert property (p_holds_pc)
    else $fatal(1, "p_holds_pc failed, hold did not hold pc");

property p_redirect_pc;
    @(posedge clk) disable iff (!reset_n_clocked)
        (redirect_enable) |=> (next_pc === $past(redirect_addr));
endproperty

assert property (p_redirect_pc)
    else $fatal(1, "p_redirect_pc failed, next_pc did not take branch");

property p_increment_pc;
    @(posedge clk) disable iff (!reset_n_clocked)
        (!hold_pc && !redirect_enable) |=> (next_pc === ($past(next_pc) + TOTAL_INSN_BYTES));
endproperty

assert property (p_increment_pc)
    else $fatal(1, "p_increment_pc failed, next_pc did not increment correctly");

logic [31:0] exp_pc;
logic hold;
logic redir_en;
logic [31:0] redir_addr;

initial begin
    $display("programCounter module test begins.");
    reset_pc();

    // reset_pc() causes the pc to start at 8 (quirk of how it works)
    exp_pc = 32'h8;
    hold = 0;
    redir_en = 0;
    redir_addr = 32'b0;

    // test simple pc increment
    repeat (5) begin
        change_inputs(hold, redir_en, redir_addr);
        exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
        tick_pc(exp_pc);
    end

    // check holding
    hold = 1;
    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    // release hold and check simple increment
    hold = 0;
    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    // check branching/jumping
    redir_en = 1;
    redir_addr = 32'h00000010;
    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    // release branch and check simple increment
    redir_en = 0;
    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    // check redirect and hold fall-through behavior
    redir_en = 1;
    redir_addr = 32'h00000010;
    hold = 1;

    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    redir_en = 0;
    change_inputs(hold, redir_en, redir_addr);
    exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
    tick_pc(exp_pc);

    // randomization stress test

    repeat (50) begin
        hold = ($urandom_range(0, 9)) < 2; // 20% holds
        redir_en = ($urandom_range(0, 9)) == 0; // 10% redirects
        redir_addr = $urandom() & 32'hFFFFFFFC; // ensure alignment

        change_inputs(hold, redir_en, redir_addr);
        exp_pc = expected_change(exp_pc, hold, redir_en, redir_addr);
        tick_pc(exp_pc);
    end

    $display("Success! PC Testbench passed.");
    $finish;
end

endmodule
