`timescale 1ns / 1ps

module async_fifo_tb;

    parameter DATA_WIDTH = 8;
    parameter ADDR_WIDTH = 4;

    logic                  wclk;
    logic                  wrst_n;
    logic                  winc;
    logic [DATA_WIDTH-1:0] wdata;
    logic                  wfull;

    logic                  rclk;
    logic                  rrst_n;
    logic                  rinc;
    logic [DATA_WIDTH-1:0] rdata;
    logic                  rempty;

    async_fifo #(
        .DATA_WIDTH(DATA_WIDTH),
        .ADDR_WIDTH(ADDR_WIDTH)
    ) uut (
        .wclk(wclk),
        .wrst_n(wrst_n),
        .winc(winc),
        .wdata(wdata),
        .wfull(wfull),
        .rclk(rclk),
        .rrst_n(rrst_n),
        .rinc(rinc),
        .rdata(rdata),
        .rempty(rempty)
    );

    initial begin
        wclk = 0;
        forever #5 wclk = ~wclk;
    end

    initial begin
        rclk = 0;
        forever #12.5 rclk = ~rclk;
    end

    initial begin
        wrst_n = 0;
        winc   = 0;
        wdata  = '0;
        rrst_n = 0;
        rinc   = 0;

        #30;
        wrst_n = 1;
        rrst_n = 1;
        #20;

        @(negedge wclk);
        for (int i = 0; i < 16; i++) begin
            winc  = 1;
            wdata = i * 10 + 5; 
            @(negedge wclk);
            
            if (wfull) begin
                break;
            end
        end
        winc = 0;

        #100;

        @(negedge rclk);
        while (!rempty) begin
            rinc = 1;
            @(negedge rclk);
        end
        rinc = 0;

        #50;
        $finish;
    end

endmodule