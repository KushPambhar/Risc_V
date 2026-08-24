module immgen(instruction,offset);
    input [31:0] instruction;
    output reg [31:0] offset;
    wire [ 6:0] opcode = instruction[6:0];

    always@(*) begin 
        case (opcode)
            7'b0000011 : offset ={{20{instruction[31]}},instruction[31:20]}; // I type (Load Type instr.)
            7'b0010011 : offset ={{20{instruction[31]}},instruction[31:20]}; // I type (Immediate Type instr.)
            7'b0100011 : offset = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]}; // S Type
            7'b1100111 : offset = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8]}; // SB Type
            default : offset = 32'b0; 
        endcase
    end

endmodule
