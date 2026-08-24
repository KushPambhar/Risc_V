module top(input clk,reset);
    wire [31:0] pc_next,pc_next_1,pc_next_2,pc_out;
    
    wire [31:0]instruction_out;
    wire [6:0]instruction_control;
    wire [4:0]rs1,rs2,rd;
    wire [31:0]write;
    wire [31:0] read_1,read_2,Read_data;
    wire Branch,MemRead, MemtoReg, MemWrite,ALUSrc,RegWrite;
    wire [1:0]ALUOp;
    wire [31:0]offset;
    wire [31:0]input1 , input2;
    wire zero;
    wire [31:0]alu_out;
    wire [3:0]alu_control;
    wire [3:0]instruction_alu;
    wire [3:0]Alu_cntrl_out;
    pc u_pc(pc_next,clk,reset, pc_out);
    inst_mem u_inst_mem(pc_out,instruction_out);
    immgen u_immgen(instruction_out,offset);
    assign instruction_control= instruction_out[6:0];
    assign rs1 = instruction_out[19:15];
    assign rs2 = instruction_out[24:20];
    assign rd = instruction_out[11:7];
    control u_control(instruction_control,Branch,MemRead, MemtoReg,ALUOp, MemWrite,ALUSrc,RegWrite);
    reg_file u_reg_file(clk,rs1,rs2,rd,write,read_1,read_2,RegWrite);
    

    assign input1 = read_1;
    assign input2 = ALUSrc ? offset : read_2; 

    assign instruction_alu = {instruction_out[30],instruction_out[14:12]};
    Alu_ctrl u_Alu_ctrl(ALUOp,instruction_alu,Alu_cntrl_out);
    assign alu_control = Alu_cntrl_out;
    ALU u_ALU(input1,input2,alu_control,alu_out,zero);

    data_mod u_data_mod(alu_out, clk,read_2, Read_data, MemRead, MemWrite);

    assign write = MemtoReg ? Read_data : alu_out;

    assign pc_next_1 = pc_out + 1;
    assign pc_next_2 = pc_out + offset;

    assign pc_next = (Branch&zero) ? pc_next_2 : pc_next_1;


    
endmodule
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
                MemtoReg = 1'b?;
                ALUOp =2'b00;
                MemWrite =1'b1;
                ALUSrc =1'b1;
                RegWrite =1'b0;
            end
            7'b1100011: begin
                Branch =1'b1;
                MemRead = 1'b0;
                MemtoReg = 1'b?;
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
module data_mod(data_address, clk,write_data, Read_data, MemRead, MemWrite);
    input [31:0] data_address, write_data;
    input MemRead,MemWrite,clk;
    output reg [31:0] Read_data;


    reg [31:0] mem [0:63];
    initial $readmemh("dmem.hex", mem);
    always@(*) begin 
        Read_data = 32'b0;
        if(MemRead)
            Read_data = mem[data_address];
    end

    always@(posedge clk) begin 
        if(MemWrite)
            mem[data_address] <= write_data;
    end
endmodule

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

module inst_mem(address, instruction_out);
    input [31:0] address;
    output reg [31:0] instruction_out;
    reg [31:0] mem [0:63];
    
    initial $readmemh("imem.hex",mem);
    assign instruction_out=mem[address[31:2]];


endmodule
module pc(next_pc, clk, reset, pc_out);
    input [31:0]next_pc;
    input clk,reset;
    output  reg [31:0]pc_out;
    always @(posedge clk or posedge reset) begin 
        if(reset)
            pc_out<=32'b0;
        else
            pc_out<=next_pc;
    
    end
endmodule
module reg_file(clk, rs1, rs2, rd, write , read_1, read_2 , regWrite);
    input clk, regWrite;
    input [4:0] rs1,rs2,rd;
    input [31:0] write;
    output reg [31:0] read_1,read_2;

    reg [31:0] registers [31:0];
    always @(*) begin
        read_1 =  registers[rs1];
        read_2 = registers[rs2];
    end
    always @(posedge clk) begin 
        if(regWrite)
            registers[rd]<=write;
    end

endmodule