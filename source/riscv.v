module riscv(input clk,reset);
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

    data_mod u_data_mod(alu_out,clk,read_2, Read_data, MemRead, MemWrite);

    assign write = MemtoReg ? Read_data : alu_out;

    assign pc_next_1 = pc_out + 1;
    assign pc_next_2 = pc_out + offset;

    assign pc_next = (Branch&zero) ? pc_next_2 : pc_next_1;


    
endmodule