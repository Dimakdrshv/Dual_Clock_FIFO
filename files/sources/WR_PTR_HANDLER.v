`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/WR_PTR_HANDLER.v
// Author: Kudryashov D.S.
// Created On: 2026-05-25 23:36:23
// Description: [wrap_bit][addr] - ptr
//===========================================================


module WR_PTR_HANDLER
#(
    parameter PTR_WDT = 3,
    parameter ALMOST_FULL_VALUE = 2
)
(
    // System signals   
    input wire wclk, // write clk domain
    input wire wrst_n, // wrire rst_n domain
    input wire w_en, // write en domain
    
    // Pointers
    output reg  [PTR_WDT : 0] wptr_b, // binary write ptr
    output wire [PTR_WDT : 0] wptr_g, // gray write ptr
    input  wire [PTR_WDT : 0] rptr_g_sync, // gray read ptr synchronized
    
    // Flags
    output reg full, // full flag
    output reg almost_full // almost full flag 
);
    
    localparam SIZE = {(PTR_WDT){1'b1}};
    
    wire [PTR_WDT : 0] rptr_b_sync; // binary read ptr
    
    GRAY_TO_BINARY 
    #(
        .PTR_WDT(PTR_WDT)
    )
    g2b
    (
        .wrptr_g(rptr_g_sync), // write or read ptr **gray code
        .wrptr_b(rptr_b_sync)  // write or read ptr **binary
    );
    
    BINARY_TO_GRAY 
    #(
        .PTR_WDT(PTR_WDT)
    )
    b2g
    (
        .wrptr_b(wptr_b), // write or read ptr **binary
        .wrptr_g(wptr_g)  // write or read ptr **gray code
    );
    
    reg [PTR_WDT : 0] wptr_b_next;      // next write pointer value
    reg               wrap_around;      // write pointer overtakes the read pointer
    reg               full_next;        // next full value
    reg               almost_full_next; // next almost full value
    
    always @* begin
        wptr_b_next = wptr_b + 1'b1;
    end
    
    always @* begin
        wrap_around = (wptr_b_next[PTR_WDT] != rptr_b_sync[PTR_WDT]);
    end
    
    always @* begin
        full_next = (wptr_b_next[PTR_WDT - 1 : 0] == rptr_b_sync[PTR_WDT - 1 : 0]) && wrap_around;
    end
    
    reg [PTR_WDT : 0] sub_reg;
    always @* begin
        sub_reg = (SIZE - (wptr_b_next[PTR_WDT : 0] - rptr_b_sync[PTR_WDT : 0]));
        almost_full_next = (sub_reg <= ALMOST_FULL_VALUE) && (sub_reg != 0);
    end
    
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            wptr_b <= 'b0;
        end else begin
            if (w_en && !full) begin
                wptr_b <= wptr_b_next;
            end
        end
    end
    
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            full <= 1'b0;
        end else begin
            full <= full_next;
        end
    end
    
    always @(posedge wclk or negedge wrst_n) begin
        if (!wrst_n) begin
            almost_full <= 1'b0;
        end else begin
            almost_full <= almost_full_next;
        end
    end
    
endmodule
