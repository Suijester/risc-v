module cacheController (
    input logic clk,
    input logic reset,

    input logic cacheHit,
    input logic [31:0] pcAddress,
    input logic [63:0] fetchedData,

    output logic pcStallCache,
    output logic ifidCacheClear,

    output logic [3:0] writeIndex,
    output logic [24:0] writeTag,
    output logic instructionRequest, // if we need to get instruction from memory
    output logic [63:0] writeData,

    output logic [31:0] instructionAddress,

    input logic receivedInstruction, // received instruction from instruction memory
    output logic writeCache // write the data to cache
);

// states for cacheController
typedef enum logic [0:0] {
    initialState = 1'b0,
    waitForInstruction = 1'b1
} cacheState;

logic [31:0] savedPCAddress;
cacheState nextState;
cacheState currentState;

always_ff @(posedge clk or negedge reset) begin
    currentState <= (!reset) ? initialState : nextState; // state advancement sequentially
    savedPCAddress <= (currentState == initialState) ? pcAddress : savedPCAddress;
end

always_comb begin
    nextState = currentState;

    pcStallCache = 0;
    ifidCacheClear = 0;
    instructionRequest = 0;

    writeCache = 0;
    writeData = 0;
    writeIndex = 0;
    writeTag = 0;
    instructionAddress = 0;

    unique case (currentState) begin
        initialState: begin
            nextState = (~cacheHit) ? waitForInstruction : initialState;
            pcStallCache = ~cacheHit;
            ifidCacheClear = ~cacheHit;
            instructionRequest = ~cacheHit;
            instructionAddress = pcAddress;
        end

        waitForInstruction: begin
            if (receivedInstruction) begin
                writeData = fetchedData;
                writeIndex = savedPCAddress[6:3];
                writeTag = savedPCAddress[31:7];
                writeCache = 1;
                nextState = initialState;

                pcStallCache = 1;
            end else begin
                nextState = waitForInstruction;
                pcStallCache = 1;
                ifidCacheClear = 1;
                instructionRequest = 1;
            end
        end
    endcase
end


