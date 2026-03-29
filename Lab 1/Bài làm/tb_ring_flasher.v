`timescale 1ns/1ps

module tb_ring_flash_regression;

reg         clk;
reg         rst_n;
reg         rep_en;
wire [15:0] led;

ring_flash16 #(
    .STEP_DIV(2)
) dut (
    .clk   (clk),
    .rst_n (rst_n),
    .rep_en(rep_en),
    .led   (led)
);

always #5 clk = ~clk;

initial begin
    $display("=== TB START ===");
    $recordfile("waves_multi");
    $recordvars("depth=0", tb_ring_flash_regression);
end

initial begin
    clk   = 1'b0;
    rst_n = 1'b0;
    rep_en = 1'b0;

    // -------------------------
    // TEST 1: reset + single start/stop
    // -------------------------
    $display("[TEST 1] reset + single run");
    #20;
    rst_n = 1'b1;
    #20;
    rep_en = 1'b1;
    #20;
    rep_en = 1'b0;

    // ch? d? lâu d? DUT t? ch?y xong 1 vòng
    #1200;

    // -------------------------
    // TEST 2: gi? rep_en = 1 d? l?p nhi?u l?n
    // -------------------------
    $display("[TEST 2] repeat multiple cycles");
    rep_en = 1'b1;
    #2000;
    rep_en = 1'b0;

    // ch? DUT d?ng h?n
    #1200;

    // -------------------------
    // TEST 3: reset gi?a lúc dang ch?y
    // -------------------------
    $display("[TEST 3] reset during run");
    rep_en = 1'b1;
    #400;
    rst_n = 1'b0;
    #30;
    rst_n = 1'b1;
    #400;
    rep_en = 1'b0;

    #800;

    $display("=== TB FINISH ===");
    $finish;
end

endmodule