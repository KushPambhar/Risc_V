module Alu_ctrl (ALUOp, instruction_alu, Alu_cntrl_out);
    input [1:0] ALUOp;
    input [3:0]instruction_alu;
    output reg [3:0] Alu_cntrl_out;

    always @(*) begin 
        case (ALUOp)
            2'b00: Alu_cntrl_out = 4'b0010;
            2'b01: Alu_cntrl_out = 4'b0110;
            default:
                case(instruction_alu[2:0])
                    3'b000 : Alu_cntrl_out = instruction_alu[3] ? 4'b0110 : 4'b0010;
                    3'b111 : Alu_cntrl_out = 4'b0000;
                    default : Alu_cntrl_out = 4'b0001;
                endcase
        endcase
    end
endmodule