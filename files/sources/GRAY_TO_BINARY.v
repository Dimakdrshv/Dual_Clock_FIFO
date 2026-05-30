`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/GRAY_TO_BINARY.v
// Author: 
// Created On: 2026-05-26 00:04:54
// Description: 
//===========================================================


module GRAY_TO_BINARY
#(
    parameter PTR_WDT = 3
)
(
    input  wire [PTR_WDT : 0] wrptr_g, // write or read ptr **gray code
    output wire [PTR_WDT : 0] wrptr_b  // write or read ptr **binary
);


    assign wrptr_b[PTR_WDT] = wrptr_g[PTR_WDT];
    
    genvar i;
    generate
        for (i = PTR_WDT - 1; i >= 0; i = i - 1) begin: genblk
            assign wrptr_b[i] = wrptr_b[i + 1] ^ wrptr_g[i];
        end
    endgenerate 


endmodule
