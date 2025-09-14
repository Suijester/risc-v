# Pipelined RISC-V with Hazard Detection & L1 Instruction Cache
**Achieved 100 MHz clock speed with 0.5ns of positive slack. <br> Met all power and timing constraints with <10% resource usage.**

Synthesizable RV32I soft-core processor implemented in SystemVerilog, designed to maximize throughput and minimize latency using a five-stage pipeline and L1 instruction cache. Features instruction and data memory synthesizable to BRAM, with single-port read & write for lightweight operations. Handles hazards through a robust hazard detection unit, utilizing data forwarding and static branch-not-taken prediction.

## Features
- RV32I ALU Operations
- Five-Stage Pipeline
- Hazard Detection & Stalling
- Register Forwarding
- L1 Instruction Cache
- Static Branch Prediction

## Pipelining
### Instruction Fetch Stage
During the Instruction Fetch stage, the program counter provides an address from which to retrieve the current instruction. Instructions are fetched from a direct-mapped L1 instruction cache. On a cache hit, the instruction is immediately provided to the IF/ID Register to begin the decoding stage. Otherwise, the overseeing cache controller module immediately stalls the program counter and clears IF/ID, and sends a request to fetch the instruction from memory. Once fetched, the instruction is immediately forwarded to the IF/ID register, and on clock edge, IF/ID processes the instruction, the L1 cache writes the instruction, and a new instruction address is received from the program counter.

### Instruction Decode Stage
An instruction is passed from the Instruction Fetch stage into the Instruction Decode stage. Through the decoder and control unit modules, the instruction is converted to signals that indicate its corresponding ALU operation and immediate value, alongside what inputs to use and whether it's a branch type instruction, etc. All signals are passed to the ID/EX register upon completion.

### Execute Stage
After receiving the signals from the Instruction Decode stage, the Execute stage calculates the output value through the ALU, after combinationally determining what inputs to use, in case a different input is used or forwarding is necessary. Forwarding is determined in this stage, and if any register is used in an instruction currently in Memory Access or Write Back, the expected write-back value is used instead. Furthermore, in this stage, the branch address is calculated and passed to the EX/MEM register, so branch-type instructions can be performed in Memory Access.

### Memory Access Stage
During the Memory Access stage, store-type and load-type instructions are performed by accessing data memory. Combinationally, the success of branch-type instructions is determined, and the result is passed back to the program counter. If the branch succeeds, IF/ID, ID/EX, and EX/MEM registers are all cleared, since it violates the static branch-not-taken. After store-type and load-type instructions occur, signals are passed to the Write Back stage to prepare to write to registers for load-type and other instruction types.

### Write Back Stage
For instructions that write to registers, the write-back stage passes the output value determined from the Execute stage to these registers. The data being written to the registers are combinationally determined in this stage, dependent on a signal passed from Instruction Decode.

## Hazard Detection
### Load Hazard
Load Hazards occur when we are forced to wait for the result of a load-type instruction, as a result of forwarding, e.g. lw x1, 4(x2), then add x2, x1, x0. To counteract these hazards, the current instruction in the Instruction Decode stage is paused for a cycle, until the result of the load is acquired. The result of the load-type instruction is then forwarded to the waiting instruction when it reaches Execute stage.

### Control Hazard (Branch Failure)
Branch hazards occur as a result of static branch prediction, which in this case, would be always-not-taken. The pipeline defaults to taking the sequential instruction, and always assumes that the branch will not be taken. However, in the event that a branch actually occurs, the pipeline must be reset, as any of the subsequent instructions after the branch will be invalid, since the processor defaults to assuming the branch fails. To counteract branch hazards, the processor wipes every pipeline register besides MEM/WB, and begins to take program counter addresses starting from the branched address.

## L1 Cache
The L1 Cache is implemented directly for instruction memory. Any time the program counter provides an address from which to retrieve an instruction, the cache is accessed. On a hit, the instruction is acquired and passed to the IF/ID register. On a miss, the cache controller module immediately freezes the program counter, preventing it from providing new instruction addresses, and additionally continuously clears the IF/ID register. The cache controller simultaneously sends a request to internal memory to recover the instruction, and the memory immediately forwards the instruction code directly to the IF/ID register, and passes the instruction data to be written to the L1 Cache. Simultaneously on clock edge, the cache writes the provided data, the current instruction is passed to Instruction Decode stage, and a new instruction is retrieved from the program counter.