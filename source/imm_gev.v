module immgen(instruction,offset);
    input [31:0] instruction;
    output reg [31:0] offset;
    wire [ 6:0] opcode = instruction[6:0];

    always@(*) begin 
        case (opcode)
            7'b0000011 : offset ={{20{instruction[31]}},instruction[31:20]};
            7'b0100011 : offset = {{20{instruction[31]}}, instruction[31:25], instruction[11:7]};
            7'b1100011 : offset = {{19{instruction[31]}}, instruction[31], instruction[7], instruction[30:25], instruction[11:8], 1'b0};
            default : offset = 32'b0; 
        endcase
    end

endmodule