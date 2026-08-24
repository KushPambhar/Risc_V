// =============================================================
// Testbench — RV32I Single-Cycle Processor
// Tests: LW, ADD, SUB, AND, OR, SW, BEQ
// Expected results:
//   x1 = 10   (lw from mem[0])
//   x2 = 3    (lw from mem[1])
//   x3 = 13   (add x1+x2)
//   x4 = 7    (sub x1-x2)
//   x5 = 2    (and x1&x2)
//   x6 = 11   (or  x1|x2)
//   mem[2] = 13 (sw x3)
// =============================================================

`timescale 1ns/1ps

module testbench;

    // ── Inputs to processor ───────────────────────────
    reg clk;
    reg reset;

    // ── Instantiate your processor ────────────────────
    riscv u_top (
        .clk   (clk),
        .reset (reset)
    );

    // ── Clock generation — 10ns period ───────────────
    initial clk = 0;
    always #5 clk = ~clk;




    // ── Cycle counter for debugging ───────────────────
    integer cycle = 0;
    always @(posedge clk) begin
        if (!reset) cycle = cycle + 1;
        $monitor("instruction_out = %h | rs1 = %b | instruction_control = %b | rs1 = %b | rs2 = %b | rd = %b ",u_top.instruction_out,u_top.rs1,u_top.instruction_control,u_top.rs1,u_top.rs2,u_top.rd);
    end

    // assign u_top.u_pc.next_pc=32'b0;
    integer i;
    initial begin
        for (i = 0; i < 32; i = i + 1)
            u_top.u_reg_file.registers[i] = 0;
    end

    // ── Main test sequence ────────────────────────────
    initial begin

        // save waveform to file
        $dumpfile("wave.vcd");
        $dumpvars(0, testbench);

        // ── Reset ─────────────────────────────────────
        reset = 1;
        $display("=== Reset asserted ===");
        @(posedge clk); #1;
        @(posedge clk); #1;
        reset = 0;
        $display("=== Reset released — processor running ===\n");

        // ── Watch each cycle ──────────────────────────
        repeat(15) begin
            @(posedge clk); #1;
            $display("Cycle %02d | PC=%0h | instr=%h | alu_out=%0d",
                cycle,
                u_top.pc_out,
                u_top.instruction_out,
                u_top.alu_out
            );
        end

        // ── Print final register values ───────────────
        $display("\n=== Final Register File ===");
        $display("x0  = %0d  (expect 0  — hardwired zero)", u_top.u_reg_file.registers[0]);
        $display("x1  = %0d  (expect 10 — lw x1, 0(x0))",  u_top.u_reg_file.registers[1]);
        $display("x2  = %0d  (expect 3  — lw x2, 4(x0))",  u_top.u_reg_file.registers[2]);
        $display("x3  = %0d  (expect 13 — add x3,x1,x2)",  u_top.u_reg_file.registers[3]);
        $display("x4  = %0d  (expect 7  — sub x4,x1,x2)",  u_top.u_reg_file.registers[4]);
        $display("x5  = %0d  (expect 2  — and x5,x1,x2)",  u_top.u_reg_file.registers[5]);
        $display("x6  = %0d  (expect 11 — or  x6,x1,x2)",  u_top.u_reg_file.registers[6]);

        // ── Print data memory ─────────────────────────
        $display("\n=== Data Memory ===");
        $display("mem[0] = %0d  (expect 10 — initial value)",  u_top.u_data_mod.mem[0]);
        $display("mem[1] = %0d  (expect 3  — initial value)",  u_top.u_data_mod.mem[4]);
        $display("mem[2] = %0d  (expect 13 — sw x3, 8(x0))",  u_top.u_data_mod.mem[8]);

        // ── Pass / Fail check ─────────────────────────
        $display("\n=== PASS / FAIL ===");

        if (u_top.u_reg_file.registers[1] == 32'd10)
            $display("x1  PASS");
        else
            $display("x1  FAIL — got %0d", u_top.u_reg_file.registers[1]);

        if (u_top.u_reg_file.registers[2] == 32'd3)
            $display("x2  PASS");
        else
            $display("x2  FAIL — got %0d", u_top.u_reg_file.registers[2]);

        if (u_top.u_reg_file.registers[3] == 32'd13)
            $display("x3  PASS");
        else
            $display("x3  FAIL — got %0d", u_top.u_reg_file.registers[3]);

        if (u_top.u_reg_file.registers[4] == 32'd7)
            $display("x4  PASS");
        else
            $display("x4  FAIL — got %0d", u_top.u_reg_file.registers[4]);

        if (u_top.u_reg_file.registers[5] == 32'd2)
            $display("x5  PASS");
        else
            $display("x5  FAIL — got %0d", u_top.u_reg_file.registers[5]);

        if (u_top.u_reg_file.registers[6] == 32'd11)
            $display("x6  PASS");
        else
            $display("x6  FAIL — got %0d", u_top.u_reg_file.registers[6]);

        if (u_top.u_data_mod.mem[8] == 32'd13)
            $display("mem[2] PASS");
        else
            $display("mem[2] FAIL — got %0d", u_top.u_data_mod.mem[2]);

        $display("\n=== Simulation complete ===");
        $finish;
    end

endmodule