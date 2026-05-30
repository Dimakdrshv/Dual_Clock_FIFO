`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/BINARY_TO_GRAY.v
// Author: Kudryashov D.S.
// Created On: 2026-05-26 00:04:39
// Description: 
//===========================================================


module BINARY_TO_GRAY 
#(
    parameter PTR_WDT = 3
)
(
    input  wire [PTR_WDT - 1 : 0] wrptr_b, // write or read ptr **binary
    output wire [PTR_WDT - 1 : 0] wrptr_g  // write or read ptr **gray code
);

    assign wrptr_g = wrptr_b ^ (wrptr_b >> 1);

endmodule
