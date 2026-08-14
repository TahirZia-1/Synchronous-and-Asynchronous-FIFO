`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 05:42:28 PM
// Design Name: 
// Module Name: tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps

module sync_fifo_tb;

    localparam int DATA_WIDTH = 8;
    localparam int DEPTH      = 8;

    logic                  clk;
    logic                  rst;
    logic [DATA_WIDTH-1:0] din;
    logic                  w_en;
    logic                  r_en;
    logic [DATA_WIDTH-1:0] dout;
    logic                  full;
    logic                  empty;

    sync_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .DEPTH(DEPTH)
    ) dut (
        .clk(clk),
        .rst(rst),
        .din(din),
        .w_en(w_en),
        .r_en(r_en),
        .dout(dout),
        .full(full),
        .empty(empty)
    );

    always begin
        clk = 0; #10;
        clk = 1; #10;
    end

    initial begin
        $display("==================================================================================================");
        $display("TIME      CLK RST WEn REn  DIN DOUT WPTR RPTR    FULL  EMPTY");
        $display("==================================================================================================");
        forever begin
            $display("%-9d %b   %b   %b   %b   %h   %h     %d     %d     %b     %b", 
                     $time, clk, rst, w_en, r_en, din, dout, dut.wptr, dut.rptr, full, empty);
            #5; 
        end
    end

    initial begin
        din  = '0;
        w_en = 0;
        r_en = 0;

        rst = 1;
        @(posedge clk);
        #1; 
        rst = 0;

        // --- TEST-1 : Single Write ---
        $display("\n========== TEST-1 : Single Write ==========\n");
        write_data(8'h11);
        idle_cycles(1);

        // --- TEST-2 : Single Read ---
        $display("\n========== TEST-2 : Single Read ==========\n");
        read_data();
        idle_cycles(1);

        // --- TEST-3 : Multiple Writes ---
        $display("\n========== TEST-3 : Multiple Writes ==========\n");
        write_data(8'h01);
        write_data(8'h02);
        write_data(8'h03);
        write_data(8'h04);
        write_data(8'h05);
        write_data(8'h06);
        write_data(8'h07);
        write_data(8'h08);
        idle_cycles(1);

        // --- TEST-4 : Multiple Reads ---
        $display("\n========== TEST-4 : Multiple Reads ==========\n");
        repeat(8) read_data();
        idle_cycles(1);

        // --- TEST-5 : Fill FIFO ---
        $display("\n========== TEST-5 : Fill FIFO ==========\n");
        write_data(8'h14); write_data(8'h15); write_data(8'h16); write_data(8'h17);
        write_data(8'h18); write_data(8'h19); write_data(8'h1a); write_data(8'h1b);
        write_data(8'h1c); write_data(8'h1d); write_data(8'h1e); write_data(8'h1f);
        write_data(8'h20); write_data(8'h21); write_data(8'h22); write_data(8'h23);
        idle_cycles(1);

        // --- TEST-6 : Overflow Test ---
        $display("\n========== TEST-6 : Overflow Test ==========\n");
        write_data(8'hFF); // Will attempt to write while full
        idle_cycles(1);

        // --- TEST-7 : Empty FIFO ---
        $display("\n========== TEST-7 : Empty FIFO ==========\n");
        repeat(12) read_data(); // Completely drain remaining items

        #100;
        $finish;
    end

    task automatic write_data(input logic [DATA_WIDTH-1:0] data);
        @(posedge clk);
        #1;
        w_en = 1; r_en = 0; din = data;
    endtask

    task automatic read_data();
        @(posedge clk);
        #1;
        w_en = 0; r_en = 1;
    endtask

    task automatic idle_cycles(input int cycles);
        int i;
        for(i=0; i<cycles; i++) begin
            @(posedge clk);
            #1;
            w_en = 0; r_en = 0;
        end
    endtask

endmodule