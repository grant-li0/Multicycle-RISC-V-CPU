import cpu_pkg::*;

`timescale 1ns/1ps

module tb_decode;

    logic [31:0] instr_i;
    instr_type_e instr_type_o;
    logic [31:0] immediate_o;

    decode dut (
        .instr_i(instr_i),
        .instr_type_o(instr_type_o),
        .immediate_o(immediate_o)
    );

    initial begin
        instr_i = 32'h00500093; #1;
        if (instr_type_o == ADDI && immediate_o == 32'h00000005) begin
            $display("PASS: ADDI positive");
        end else begin
            $fatal(1, "FAIL: ADDI positive: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'hFFF00093; #1;
        if (instr_type_o == ADDI && immediate_o == 32'hFFFFFFFF) begin
            $display("PASS: ADDI negative");
        end else begin
            $fatal(1, "FAIL: ADDI negative: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h002081B3; #1;
        if (instr_type_o == ADD && immediate_o == 32'h00000000) begin
            $display("PASS: ADD");
        end else begin
            $fatal(1, "FAIL: ADD: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h402081B3; #1;
        if (instr_type_o == SUB && immediate_o == 32'h00000000) begin
            $display("PASS: SUB");
        end else begin
            $fatal(1, "FAIL: SUB: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h002091B3; #1;
        if (instr_type_o == SLL && immediate_o == 32'h00000000) begin
            $display("PASS: SLL");
        end else begin
            $fatal(1, "FAIL: SLL: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h0020D1B3; #1;
        if (instr_type_o == SRL && immediate_o == 32'h00000000) begin
            $display("PASS: SRL");
        end else begin
            $fatal(1, "FAIL: SRL: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h0040A183; #1;
        if (instr_type_o == LOAD && immediate_o == 32'h00000004) begin
            $display("PASS: LOAD positive offset");
        end else begin
            $fatal(1, "FAIL: LOAD positive offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'hFFC0A183; #1;
        if (instr_type_o == LOAD && immediate_o == 32'hFFFFFFFC) begin
            $display("PASS: LOAD negative offset");
        end else begin
            $fatal(1, "FAIL: LOAD negative offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h0020A623; #1;
        if (instr_type_o == STORE && immediate_o == 32'h0000000C) begin
            $display("PASS: STORE positive offset");
        end else begin
            $fatal(1, "FAIL: STORE positive offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'hFE20AE23; #1;
        if (instr_type_o == STORE && immediate_o == 32'hFFFFFFFC) begin
            $display("PASS: STORE negative offset");
        end else begin
            $fatal(1, "FAIL: STORE negative offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h00008463; #1;
        if (instr_type_o == BEQ && immediate_o == 32'h00000008) begin
            $display("PASS: BEQ positive offset");
        end else begin
            $fatal(1, "FAIL: BEQ positive offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'hFE008EE3; #1;
        if (instr_type_o == BEQ && immediate_o == 32'hFFFFFFFC) begin
            $display("PASS: BEQ negative offset");
        end else begin
            $fatal(1, "FAIL: BEQ negative offset: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h00100073; #1;
        if (instr_type_o == EBREAK && immediate_o == 32'h00000000) begin
            $display("PASS: EBREAK");
        end else begin
            $fatal(1, "FAIL: EBREAK: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        instr_i = 32'h4020D1B3; #1;
        if (instr_type_o == NOP && immediate_o == 32'h00000000) begin
            $display("PASS: unsupported SRA");
        end else begin
            $fatal(1, "FAIL: unsupported SRA: type=%0d immediate=%h", instr_type_o, immediate_o);
        end

        $display("RESULT: ALL 14 TESTS PASSED");
        $finish;
    end

endmodule
