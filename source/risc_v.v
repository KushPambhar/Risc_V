

module top(input clk, input reset);
    wire [31:0] pc_in, pc_out;

    wire [31:0] Instruction;

    wire Branch, MemRead, MemtoReg, MemWrite, AluSrcB, RegWrite;
    wire [1:0] AluOP, AluSrcA;

    wire [31:0] ReadData1, ReadData2;

    wire [31:0] Imm_Gen_Out;

    wire [3:0] AluControlOut;

    wire [31:0] SrcAOut, SrcBOut;

    wire [31:0] AluOut;
    wire zero, lt, ltu;

    wire branch_taken;

    wire branch_and;

    wire [31:0] pc_branch;
    wire [31:0] pc_next;

    wire [31:0] DataMemoryOut;

    wire [31:0] WriteData;

    pc(pc_in, clk, reset, pc_out);

    inst_mem(pc_out, Instruction);

    reg_file(clk,Instruction[19:15],Instruction[24:20],Instruction[11:7],WriteData,ReadData1,ReadData2,RegWrite)

    immgen(Instruction,Imm_Gen_Out);

    control(Instruction[6:0],RegWrite,MemWrite,MemRead,MemtoReg,Branch,AluSrcB,AluSrcA,AluOP);

    adder a1(pc_out,32'b4,pc_next);
    adder a2(pc_out,Imm_Gen_Out,pc_branch);

    mux_4x1(ReadData1,32'b0, pc_out, 32'b0, AluSrcA ,SrcAOut);
    mux_2x1(ReadData2,Imm_Gen_Out, AluSrcB ,SrcBOut);

    ALUControl(AluOP,Instruction[14:12],Imm_Gen_Out[30],ALUControlOut);

    ALU(SrcAOut,SrcBOut, AluOut, zero, lt, ltu);

    branch_logic(Instruction[14:12],zero,lt,ltu,branch_taken);

    assign branch_and = branch_taken & Branch;

    mux_2x1(pc_next,pc_branch,branch_and, pc_in);

    data_mem(AluOut,clk,ReadData2,DataMemoryOut,MemRead,MemWrite);

    mux_2x1(AluOut,DataMemoryOut,MemtoReg,WriteData);

 
endmodule
