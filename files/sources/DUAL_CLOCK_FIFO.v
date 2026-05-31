`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/sources/DUAL_CLOCK_FIFO.v
// Author: Kudryashov D.S.
// Created On: 2026-05-31 14:35:26
// Description: FIFO_DEPTH must be 2^n; ALMOST values must be minimum 1
//===========================================================


module DUAL_CLOCK_FIFO
#(
    parameter         FIFO_DEPTH = 8,
    parameter  ALMOST_FULL_VALUE = 1,
    parameter ALMOST_EMPTY_VALUE = 1,
    parameter           DATA_WDT = 8
)
(
    // System signals
    input wire wclk,
    input wire rclk,
    input wire wrst_n,
    input wire rrst_n,
    input wire w_en,
    input wire r_en,
    
    // Data buses
    input  wire [DATA_WDT - 1 : 0] data_in,
    output wire [DATA_WDT - 1 : 0] data_out,
    
    // (almost)full/empty flags
    output wire full,
    output wire almost_full,
    output wire empty,
    output wire almost_empty
);

    localparam PTR_WDT = $clog2(FIFO_DEPTH);
    
    //--------------------> write pointer handler
    wire [PTR_WDT : 0] wptr_b;
    wire [PTR_WDT : 0] wptr_g;
    wire [PTR_WDT : 0] rptr_g_sync;
    
    WR_PTR_HANDLER
    #(
        .PTR_WDT(PTR_WDT),
        .ALMOST_FULL_VALUE(ALMOST_FULL_VALUE)
    )
    wr_ptr_handler
    (
        // System signals   
        .wclk(wclk), // write clk domain
        .wrst_n(wrst_n), // wrire rst_n domain
        .w_en(w_en), // write en domain
        
        // Pointers
        .wptr_b(wptr_b), // binary write ptr
        .wptr_g(wptr_g), // gray write ptr
        .rptr_g_sync(rptr_g_sync), // gray read ptr synchronized
        
        // Flags
        .full(full), // full flag
        .almost_full(almost_full) // almost full flag 
    );
    
    //--------------------> read pointer handler
    wire [PTR_WDT : 0] rptr_b;
    wire [PTR_WDT : 0] rptr_g;
    wire [PTR_WDT : 0] wptr_g_sync;
    
    RD_PTR_HANDLER
    #(
        .PTR_WDT(PTR_WDT),
        .ALMOST_EMPTY_VALUE(ALMOST_EMPTY_VALUE)
    )
    rd_ptr_handler
    (
        // System signals   
        .rclk(rclk), // read clk domain
        .rrst_n(rrst_n), // read rst_n domain
        .r_en(r_en), // read en domain
        
        // Pointers
        .rptr_b(rptr_b), // binary read ptr
        .rptr_g(rptr_g), // gray read ptr
        .wptr_g_sync(wptr_g_sync), // gray write ptr synchronized
        
        // Flags
        .empty(empty), // empty flag
        .almost_empty(almost_empty) // almost empty flag 
    );
    
    //--------------------> write CD synchronizer
    PTR_SYNCHRONIZER
    #(
        .PTR_WDT(PTR_WDT)
    )
    wr_ptr_synchronizer
    (
        // System signals
        .wrclk(wclk), // write or read clk domain
        .wrrst_n(wrst_n), // write or read rst_n domain
        
        // Pointers
        .wrptr(rptr_g), // write or read ptr
        .wrptr_sync(rptr_g_sync) // write or read ptr_sync
    );
    
    //--------------------> read CD synchronizer
    PTR_SYNCHRONIZER
    #(
        .PTR_WDT(PTR_WDT)
    )
    rd_ptr_synchronizer
    (
        // System signals
        .wrclk(rclk), // write or read clk domain
        .wrrst_n(rrst_n), // write or read rst_n domain
        
        // Pointers
        .wrptr(wptr_g), // write or read ptr
        .wrptr_sync(wptr_g_sync) // write or read ptr_sync
    );
    
    //--------------------> FIFO memory
    FIFO_MEM
    #(
        .FIFO_DEPTH(FIFO_DEPTH),
        .DATA_WDT(DATA_WDT)
    )
    fifo_memory
    (
        // System signals
        .wclk(wclk),
        .rclk(rclk),
        .w_en(w_en),
        .r_en(r_en),
        
        // Data buses
        .data_in(data_in),
        .data_out(data_out),
        
        // Pointers
        .wptr_b(wptr_b[PTR_WDT - 1 : 0]),
        .rptr_b(rptr_b[PTR_WDT - 1 : 0]),
        
        // full/empty flags
        .full(full),
        .empty(empty)
    );

endmodule
