`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/FIFO_MEM.v
// Author: Kudryashov D.S.
// Created On: 2026-05-31 12:49:53
// Description: FIFO_DEPTH must be 2^n for gray code
//===========================================================

module FIFO_MEM
#(
    parameter FIFO_DEPTH = 8,
    parameter DATA_WDT = 8
)
(
    // System signals
    input wire wclk,
    input wire rclk,
    input wire w_en,
    input wire r_en,
    
    // Data buses
    input  wire [DATA_WDT - 1 : 0] data_in,
    output reg  [DATA_WDT - 1 : 0] data_out,
    
    // Pointers
    input wire [$clog2(FIFO_DEPTH) - 1 : 0] wptr_b,
    input wire [$clog2(FIFO_DEPTH) - 1 : 0] rptr_b,
    
    // full/empty flags
    input wire full,
    input wire empty    
);

    (* ram_style = "block" *)
    reg [DATA_WDT - 1 : 0] mem [0 : FIFO_DEPTH - 1];
    
    always @(posedge wclk) begin
        if (w_en && !full) begin
            mem[wptr_b] <= data_in;
        end
    end
    
    always @(posedge rclk) begin
        if (r_en && !empty) begin
            data_out <= mem[rptr_b];
        end
    end

endmodule
