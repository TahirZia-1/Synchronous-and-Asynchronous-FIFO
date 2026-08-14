`timescale 1ns / 1ps

module async_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int ADDR_WIDTH = 4
)(
    input  logic                  wclk,
    input  logic                  wrst_n,
    input  logic                  winc,
    input  logic [DATA_WIDTH-1:0] wdata,
    output logic                  wfull,

    input  logic                  rclk,
    input  logic                  rrst_n,
    input  logic                  rinc,
    output logic [DATA_WIDTH-1:0] rdata,
    output logic                  rempty
);

    // Parameters
    localparam int DEPTH = 1 << ADDR_WIDTH;

    // Signals
    logic [ADDR_WIDTH:0]   wptr, rptr;
    logic [ADDR_WIDTH:0]   wq2_rptr, rq2_wptr;
    logic [ADDR_WIDTH-1:0] waddr, raddr;
    
    // Memory
    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic wclken;

    assign wclken = winc & ~wfull; 

    always_ff @(posedge wclk) begin
        if (wclken) begin
            mem[waddr] <= wdata;
        end
    end

    // Output[cite: 1]
    assign rdata = mem[raddr];

    // Synchronizer
    logic [ADDR_WIDTH:0] wq1_rptr;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            {wq2_rptr, wq1_rptr} <= '0;
        end else begin
            {wq2_rptr, wq1_rptr} <= {wq1_rptr, rptr};
        end
    end

    // Synchronizer
    logic [ADDR_WIDTH:0] rq1_wptr;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            {rq2_wptr, rq1_wptr} <= '0;
        end else begin
            {rq2_wptr, rq1_wptr} <= {rq1_wptr, wptr};
        end
    end

    // Write
    logic [ADDR_WIDTH:0] wbin, wbin_next, wgray_next;
    logic                wfull_next;

    always_ff @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            {wbin, wptr} <= '0;
            wfull        <= 1'b0;
        end else begin
            {wbin, wptr} <= {wbin_next, wgray_next};
            wfull        <= wfull_next;
        end
    end

    // Address
    assign waddr = wbin[ADDR_WIDTH-1:0];

    // Next
    assign wbin_next  = wbin + (winc & ~wfull);
    assign wgray_next = wbin_next ^ (wbin_next >> 1);

    // Full
    assign wfull_next = (wgray_next == {~wq2_rptr[ADDR_WIDTH:ADDR_WIDTH-1], wq2_rptr[ADDR_WIDTH-2:0]});

    // Read
    logic [ADDR_WIDTH:0] rbin, rbin_next, rgray_next;
    logic                rempty_next;

    always_ff @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            {rbin, rptr} <= '0;
            rempty       <= 1'b1; 
        end else begin
            {rbin, rptr} <= {rbin_next, rgray_next};
            rempty       <= rempty_next;
        end
    end

    // Address
    assign raddr = rbin[ADDR_WIDTH-1:0];

    // Next
    assign rbin_next  = rbin + (rinc & ~rempty);
    assign rgray_next = rbin_next ^ (rbin_next >> 1);

    // Empty
    assign rempty_next = (rgray_next == rq2_wptr);

endmodule