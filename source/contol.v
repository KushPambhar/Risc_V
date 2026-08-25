module control(
    input      [6:0] opcode,
    output reg        RegWrite,
    output reg        MemWrite,
    output reg        Branch,
    output reg        Jump,
    output reg        ALUSrc,      // 0 = rs2, 1 = immediate  -> ALU input B
    output reg [1:0]  ALUSrcA,     // 0 = rs1, 1 = PC, 2 = 0   -> ALU input A
    output reg [1:0]  ResultSrc,   // 00 = ALU result, 01 = Mem data, 10 = PC+4
    output reg [2:0]  ImmSrc,      // selects immediate format
    output reg [1:0]  ALUOp        // coarse op class, refined by alu_control
);
    always @(*) begin
        // ---- safe defaults (also covers illegal/unsupported opcode) ----
        RegWrite  = 1'b0;
        MemWrite  = 1'b0;
        Branch    = 1'b0;
        Jump      = 1'b0;
        ALUSrc    = 1'b0;
        ALUSrcA   = 2'b00;
        ResultSrc = 2'b00;
        ImmSrc    = 3'b000;
        ALUOp     = 2'b00;

        case (opcode)

            // ---------------- LOAD: LB/LH/LW/LBU/LHU ----------------
            7'b0000011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;      // rs1 + imm
                ALUSrcA   = 2'b00;     // rs1
                ResultSrc = 2'b01;     // write back memory data
                ImmSrc    = 3'b000;    // I-type imm
                ALUOp     = 2'b00;     // add
            end

            // ---------------- STORE: SB/SH/SW ----------------
            7'b0100011: begin
                MemWrite  = 1'b1;
                ALUSrc    = 1'b1;      // rs1 + imm
                ALUSrcA   = 2'b00;
                ImmSrc    = 3'b001;    // S-type imm
                ALUOp     = 2'b00;     // add
            end

            // ---------------- BRANCH: BEQ/BNE/BLT/BGE/BLTU/BGEU ----------------
            7'b1100011: begin
                Branch    = 1'b1;
                ALUSrc    = 1'b0;      // compare rs1 vs rs2
                ALUSrcA   = 2'b00;
                ImmSrc    = 3'b010;    // B-type imm
                ALUOp     = 2'b01;     // subtract/compare
            end

            // ---------------- I-TYPE ALU: ADDI/SLTI/.../SRAI ----------------
            7'b0010011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;      // rs1 + imm
                ALUSrcA   = 2'b00;
                ResultSrc = 2'b00;     // write back ALU result
                ImmSrc    = 3'b000;    // I-type imm
                ALUOp     = 2'b10;     // let alu_control decode funct3/funct7
            end

            // ---------------- R-TYPE ALU: ADD/SUB/.../AND ----------------
            7'b0110011: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b0;      // rs1, rs2
                ALUSrcA   = 2'b00;
                ResultSrc = 2'b00;
                ALUOp     = 2'b10;     // let alu_control decode funct3/funct7
            end

            // ---------------- LUI ----------------
            7'b0110111: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;      // imm
                ALUSrcA   = 2'b10;     // force A = 0  -> result = 0 + imm
                ResultSrc = 2'b00;
                ImmSrc    = 3'b011;    // U-type imm
                ALUOp     = 2'b00;     // add (0 + imm)
            end

            // ---------------- AUIPC ----------------
            7'b0010111: begin
                RegWrite  = 1'b1;
                ALUSrc    = 1'b1;      // imm
                ALUSrcA   = 2'b01;     // A = PC
                ResultSrc = 2'b00;
                ImmSrc    = 3'b011;    // U-type imm
                ALUOp     = 2'b00;     // add (PC + imm)
            end

            // ---------------- JAL ----------------
            7'b1101111: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ResultSrc = 2'b10;     // write back PC+4
                ImmSrc    = 3'b100;    // J-type imm
                // target = PC + imm, computed via PC-adder, not main ALU
            end

            // ---------------- JALR ----------------
            7'b1100111: begin
                RegWrite  = 1'b1;
                Jump      = 1'b1;
                ALUSrc    = 1'b1;      // rs1 + imm
                ALUSrcA   = 2'b00;     // A = rs1
                ResultSrc = 2'b10;     // write back PC+4
                ImmSrc    = 3'b000;    // I-type imm
                ALUOp     = 2'b00;     // add -> target address
            end

            // ---------------- FENCE ----------------
            7'b0001111: begin
                // treated as NOP in a simple single-cycle core
            end

            // ---------------- ECALL / EBREAK (SYSTEM) ----------------
            7'b1110011: begin
                // no register/memory write in a minimal core;
                // trap/exception handling would go here in a full design
            end

            default: begin
                // illegal opcode -> defaults above (all safe/inactive)
            end
        endcase
    end
endmodule
