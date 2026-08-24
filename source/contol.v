        module control(instruction_control,Branch,MemRead, MemtoReg,ALUOp,MemWrite,ALUSrc,RegWrite); 
    input [6:0] instruction_control;
    output reg  Branch,MemRead, MemtoReg, MemWrite,ALUSrc,RegWrite;
    output reg[1:0] ALUOp;
    always@(*)begin 
        case (instruction_control)
            7'b0000011: begin
                Branch =1'b0;
                MemRead = 1'b1;
                MemtoReg = 1'b1;
                ALUOp =2'b00;
                MemWrite =1'b0;
                ALUSrc =1'b1;
                RegWrite =1'b1;
            end
            7'b0100011: begin
                Branch =1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUOp =2'b00;
                MemWrite =1'b1;
                ALUSrc =1'b1;
                RegWrite =1'b0;
            end
            7'b1100011: begin
                Branch =1'b1;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUOp =2'b01;
                MemWrite =1'b0;
                ALUSrc =1'b0;
                RegWrite =1'b0;
            end
            default: begin 
                Branch =1'b0;
                MemRead = 1'b0;
                MemtoReg = 1'b0;
                ALUOp =2'b10;
                MemWrite =1'b0;
                ALUSrc =1'b0;
                RegWrite =1'b1;
            end 
        endcase
    end

endmodule