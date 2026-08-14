`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07/13/2026 03:22:25 PM
// Design Name: 
// Module Name: sync_fifo
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

module sync_fifo #(
    parameter int DATA_WIDTH = 8,
    parameter int DEPTH      = 8
) (
    input  logic                    clk,
    input  logic                    rst,    
    input  logic [DATA_WIDTH-1:0]   din,
    input  logic                    w_en,
    input  logic                    r_en,
    
    output logic [DATA_WIDTH-1:0]   dout,
    output logic                    full,
    output logic                    empty
);

    localparam int ADDR_WIDTH = $clog2(DEPTH);
    localparam int PTR_WIDTH  = ADDR_WIDTH + 1;

    logic [DATA_WIDTH-1:0] mem [0:DEPTH-1];
    logic [PTR_WIDTH-1:0]  wptr;
    logic [PTR_WIDTH-1:0]  rptr;

    logic [ADDR_WIDTH-1:0] waddr;
    logic [ADDR_WIDTH-1:0] raddr;
    
    assign waddr = wptr[ADDR_WIDTH-1:0];
    assign raddr = rptr[ADDR_WIDTH-1:0];


    assign empty = (wptr == rptr);
    
    assign full  = (wptr[ADDR_WIDTH] != rptr[ADDR_WIDTH]) && 
                   (wptr[ADDR_WIDTH-1:0] == rptr[ADDR_WIDTH-1:0]);
         
    logic w_accept;
    logic r_accept;
    
    assign w_accept = w_en && !full;
    assign r_accept = r_en && !empty;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wptr <= '0;
            rptr <= '0;
            dout <= '0;
        end else begin
            if (w_accept) begin
                mem[waddr] <= din;
                wptr       <= wptr + 1'b1;
            end
            
            if (r_accept) begin
                dout <= mem[raddr];
                rptr <= rptr + 1'b1;
            end
        end
    end

endmodule
