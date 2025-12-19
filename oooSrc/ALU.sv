`include "opTypes.svh"
module ALU (
    input ALU_operation_t alu_operation,
    input logic [31:0] input1_data,
    input logic [31:0] input2_data,

    output logic [31:0] result,
    output logic zero
);

assign zero = (result == 0);

always_comb begin
    unique case (alu_operation)
        addALU: result = input1_data + input2_data;
        subALU: result = input1_data - input2_data;
        xorALU: result = input1_data ^ input2_data;
        orALU: result = input1_data | input2_data;
        andALU: result = input1_data & input2_data;
        sllALU: result = input1_data << input2_data[4:0];
        srlALU: result = input1_data >> input2_data[4:0];
        sraALU: result = $signed(input1_data) >>> input2_data[4:0];
        sltALU: result = ($signed(input1_data) < $signed(input2_data)) ? 1 : 0;
        sltuALU: result = (input1_data < input2_data) ? 1 : 0;
        luiALU: result = input2_data;
        noALU: result = 32'b0;

        default: result = 32'b0;
    endcase
end

endmodule
