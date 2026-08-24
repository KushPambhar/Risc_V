module ALU(input1, input2, alu_control, alu_out, zero);
    input [31:0] input1,input2;
    input [3:0] alu_control;
    output reg [31:0] alu_out;
    output zero;
    always @(*) begin 
        case (alu_control)
                4'b0010:
                    alu_out=input1+input2;
                4'b0110:
                    alu_out=input1-input2;
                4'b0000:
                    alu_out=input1&input2;
                4'b0001: 
                    alu_out=input1|input2;
            default:
                alu_out = input1|input2;
        endcase
        end
    assign zero = (alu_out==32'b0) ? 1'b1 : 1'b0;
endmodule