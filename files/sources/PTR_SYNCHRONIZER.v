`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/PTR_SYNCHRONIZER.v
// Author: Kudryashov D.S.
// Created On: 2026-05-25 23:43:58
// Description: 
//===========================================================


module PTR_SYNCHRONIZER
#(
    parameter PTR_WDT = 3
)
(
    // System signals
    input wire wrclk, // write or read clk domain
    input wire wrrst_n, // write or read rst_n domain
    
    // Pointers
    input  wire [PTR_WDT - 1 : 0] wrptr, // write or read ptr
    output reg  [PTR_WDT - 1 : 0] wrptr_sync // write or read ptr_sync
);
    
    reg [PTR_WDT - 1 : 0] wrptr_reg;

    always @(posedge wrclk or negedge wrrst_n) begin
        if (!wrrst_n) begin
            wrptr_reg  <= 'b0;
            wrptr_sync <= 'b0;
        end else begin
            wrptr_reg  <= wrptr;
            wrptr_sync <= wrptr_reg;
        end
    end
    
endmodule
