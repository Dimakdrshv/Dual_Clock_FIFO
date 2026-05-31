`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/RD_PTR_HANDLER.v
// Author: Kudryashov D.S.
// Created On: 2026-05-31 14:23:12
// Description: [wrap_bit][addr] - ptr
//===========================================================


module RD_PTR_HANDLER
#(
    parameter PTR_WDT = 3,
    parameter ALMOST_EMPTY_VALUE = 2
)
(
    // System signals   
    input wire rclk, // read clk domain
    input wire rrst_n, // read rst_n domain
    input wire r_en, // read en domain
    
    // Pointers
    output reg  [PTR_WDT : 0] rptr_b, // binary read ptr
    output wire [PTR_WDT : 0] rptr_g, // gray read ptr
    input  wire [PTR_WDT : 0] wptr_g_sync, // gray write ptr synchronized
    
    // Flags
    output reg empty, // empty flag
    output reg almost_empty // almost empty flag 
);

    wire [PTR_WDT : 0] wptr_b_sync;
    
    GRAY_TO_BINARY 
    #(
        .PTR_WDT(PTR_WDT)
    )
    g2b
    (
        .wrptr_g(wptr_g_sync), // write or read ptr **gray code
        .wrptr_b(wptr_b_sync)  // write or read ptr **binary
    );
    
    BINARY_TO_GRAY 
    #(
        .PTR_WDT(PTR_WDT)
    )
    b2g
    (
        .wrptr_b(rptr_b), // write or read ptr **binary
        .wrptr_g(rptr_g)  // write or read ptr **gray code
    );
    
    reg [PTR_WDT : 0] rptr_b_next;       // next read pointer value                 
    reg               empty_next;        // next empty value
    reg               almost_empty_next; // next almost empty value
    
    always @* begin
        rptr_b_next = rptr_b + 1'b1;
    end
    
    always @* begin
        empty_next = (rptr_b_next[PTR_WDT : 0] == wptr_b_sync[PTR_WDT : 0]);
    end
    
    reg [PTR_WDT : 0] sub_reg;
    always @* begin
        sub_reg = wptr_b_sync[PTR_WDT : 0] - rptr_b_next[PTR_WDT : 0];
        almost_empty_next = (sub_reg <= ALMOST_EMPTY_VALUE) && (sub_reg != 0);
    end
    
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            rptr_b <= 'b0;
        end else begin
            if (r_en && !empty) begin
                rptr_b <= rptr_b_next;
            end
        end
    end
    
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            empty <= 1'b1;
        end else begin
            empty <= empty_next;
        end
    end
    
    always @(posedge rclk or negedge rrst_n) begin
        if (!rrst_n) begin
            almost_empty <= 1'b0;
        end else begin
            almost_empty <= 1'b1;
        end
    end
            
endmodule
