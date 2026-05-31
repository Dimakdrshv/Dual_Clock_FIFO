`timescale 1ps / 1ps

//===========================================================
// File Path: D:/VivadoProjects/Dual_Clock_FIFO/files/simulations/DUAL_PORT_FIFO_TB.v
// Author: Kudryashov D.S.
// Created On: 2026-05-31 16:42:53
// Description: 
//===========================================================

`define FIFO_DEPTH 32
`define ALMOST_FULL_VALUE 3
`define ALMOST_EMPTY_VALUE 2
`define DATA_WDT 16

`define WCLK_PERIOD 10
`define RCLK_PERIOD 14

module DUAL_PORT_FIFO_TB;
    
    reg wclk, wrst_n, w_en;
    reg rclk, rrst_n, r_en;
    
    reg  [`DATA_WDT - 1 : 0] data_in;
    wire [`DATA_WDT - 1 : 0] data_out;
    
    wire full, almost_full;
    wire empty, almost_empty;
    
    DUAL_CLOCK_FIFO
    #(
        .FIFO_DEPTH(`FIFO_DEPTH),
        .ALMOST_FULL_VALUE(`ALMOST_FULL_VALUE),
        .ALMOST_EMPTY_VALUE(`ALMOST_EMPTY_VALUE),
        .DATA_WDT(`DATA_WDT)
    )
    dual_clock_fifo
    (
        // System signals
        .wclk(wclk),
        .rclk(rclk),
        .wrst_n(wrst_n),
        .rrst_n(rrst_n),
        .w_en(w_en),
        .r_en(r_en),
        
        // Data buses
        .data_in(data_in),
        .data_out(data_out),
        
        // (almost)full/empty flags
        .full(full),
        .almost_full(almost_full),
        .empty(empty),
        .almost_empty(almost_empty)
    );
    
    initial begin
        wclk = 1'b0;
        rclk = 1'b0;
        wrst_n = 1'b1;
        rrst_n = 1'b1;
        w_en = 1'b0;
        r_en = 1'b0;
        data_in = 'b0;
    end
    
    always #(`WCLK_PERIOD/2) wclk = ~wclk;
    always #(`RCLK_PERIOD/2) rclk = ~rclk;
    
    task system_reset();
        begin
            #3; wrst_n = 1'b0;
            @(posedge wclk);
            #3; wrst_n = 1'b1;
            #3; rrst_n = 1'b0;
            @(posedge rclk);
            #3; rrst_n = 1'b1;
        end
    endtask
    
    task error_handler(input [4:0] error_num, input expected_flag, input [$clog2(`FIFO_DEPTH) : 0] expected_ptr, input [`DATA_WDT - 1 : 0] expected_data);
        begin
            case(error_num)
                0: $display("ERROR: full flag is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, full);
                1: $display("ERROR: almost_full flag is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, almost_full);
                2: $display("ERROR: empty flag is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, empty);
                3: $display("ERROR: almost empty flag is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, almost_empty);
                4: $display("ERROR: write pointer is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_ptr, dual_clock_fifo.wptr_b);
                5: $display("ERROR: read pointer is invalid.\nExpected: %0b.\nCurrent: %0b.", expected_ptr, dual_clock_fifo.rptr_b);
                6: $display("ERROR: data is invalid.\nExpected: %0h.\nCurrent: %0h.", expected_data, data_out);
            endcase
        end
    endtask
    
    task pass_handler(input [4:0] pass_num, input expected_flag, input [$clog2(`FIFO_DEPTH) : 0] expected_ptr, input [`DATA_WDT - 1 : 0] expected_data);
        begin
            case(pass_num)
                0: $display("PASS: full flag is valid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, full);
                1: $display("PASS: almost_full flag is valid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, almost_full);
                2: $display("PASS: empty flag is valid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, empty);
                3: $display("PASS: almost empty flag is valid.\nExpected: %0b.\nCurrent: %0b.", expected_flag, almost_empty);
                4: $display("PASS: write pointer is valid.\nExpected: %0b.\nCurrent: %0b.", expected_ptr, dual_clock_fifo.wptr_b);
                5: $display("PASS: read pointer is valid.\nExpected: %0b.\nCurrent: %0b.", expected_ptr, dual_clock_fifo.rptr_b);
                6: $display("PASS: data is valid.\nExpected: %0h.\nCurrent: %0h.", expected_data, data_out);
            endcase
        end
    endtask
    
    task check_full(input expected_value);
        reg result;
        begin
            result = expected_value == full;
            if (result) begin
                pass_handler(0, expected_value, 0, 0);
            end else begin
                error_handler(0, expected_value, 0, 0);
            end
        end
    endtask
    
    task check_almost_full(input expected_value);
        reg result;
        begin
            result = expected_value == almost_full;
            if (result) begin
                pass_handler(1, expected_value, 0, 0);
            end else begin
                error_handler(1, expected_value, 0, 0);
            end
        end
    endtask
    
    task check_empty(input expected_value);
        reg result;
        begin
            result = expected_value == empty;
            if (result) begin
                pass_handler(2, expected_value, 0, 0);
            end else begin
                error_handler(2, expected_value, 0, 0);
            end
        end
    endtask
    
    task check_almost_empty(input expected_value);
        reg result;
        begin
            result = expected_value == almost_empty;
            if (result) begin
                pass_handler(3, expected_value, 0, 0);
            end else begin
                error_handler(3, expected_value, 0, 0);
            end
        end
    endtask
    
    task check_wr_ptr(input [$clog2(`FIFO_DEPTH) : 0] expected_ptr);
        reg result;
        begin
            result = expected_ptr == dual_clock_fifo.wptr_b;
            if (result) begin
                pass_handler(4, 0, expected_ptr, 0);
            end else begin
                error_handler(4, 0, expected_ptr, 0);
            end
        end
    endtask
    
    task check_rd_ptr(input [$clog2(`FIFO_DEPTH) : 0] expected_ptr);
        reg result;
        begin
            result = expected_ptr == dual_clock_fifo.rptr_b;
            if (result) begin
                pass_handler(5, 0, expected_ptr, 0);
            end else begin
                error_handler(5, 0, expected_ptr, 0);
            end
        end
    endtask
    
    task check_mem(input [`DATA_WDT - 1 : 0] expected_data);
        reg result;
        begin
            result = data_out == expected_data;
            if (result) begin
                pass_handler(6, 0, 0, expected_data);
            end else begin
                error_handler(6, 0, 0, expected_data);
            end
        end
    endtask
    
    reg [`DATA_WDT - 1 : 0] mem [0 : `FIFO_DEPTH - 1];
    task write_full_data();
        reg [$clog2(`FIFO_DEPTH) - 1 : 0] counter;
        reg [$clog2(`FIFO_DEPTH) : 0] size;
        begin
            counter = 0;
            size = {($clog2(`FIFO_DEPTH)){1'b1}} + 1'b1;
            repeat(`FIFO_DEPTH) begin
                #1 data_in = $urandom_range({(`DATA_WDT){1'b1}}, {(`DATA_WDT){1'b0}});
                if ((size - counter <= `ALMOST_FULL_VALUE) && (size - counter != 0)) begin
                    check_almost_full(1);
                end
                mem[counter] = data_in;
                counter = counter + 1;
                #1 w_en = 1'b1;
                @(posedge wclk);
                #1;
            end
            w_en = 1'b0;
        end
    endtask
    
    task read_empty_data();
        reg [$clog2(`FIFO_DEPTH) - 1 : 0] counter;
        reg [$clog2(`FIFO_DEPTH) : 0] size;
        begin
            counter = 0;
            size = {($clog2(`FIFO_DEPTH)){1'b1}} + 1'b1;
            repeat(`FIFO_DEPTH) begin
                if ((size - counter <= `ALMOST_EMPTY_VALUE) && (size - counter != 0)) begin
                    check_almost_empty(1);
                end
                #1; r_en = 1'b1;
                @(posedge rclk);
                #1;
                check_mem(mem[counter]);
                counter = counter + 1;
            end
            r_en = 1'b0;
        end
    endtask
    
    task write_data(input [$clog2(`FIFO_DEPTH) - 1 : 0] index);
        begin
            #1 data_in = $urandom_range({(`DATA_WDT){1'b1}}, {(`DATA_WDT){1'b0}});
            mem[index] = data_in;
            #1 w_en = 1'b1;
            @(posedge wclk);
            #1;
            w_en = 1'b0;
        end
    endtask
    
    task read_data(input [$clog2(`FIFO_DEPTH) - 1 : 0] index);
        begin
            #1 r_en = 1'b1;
            @(posedge rclk);
            #1;
            check_mem(mem[index]);
            r_en = 1'b0;
        end
    endtask
    
    task reset_test();
        begin
            $display("================= RESET TEST =================");
            system_reset();
            check_full(0);
            check_almost_full(0);
            check_empty(1);
            check_almost_empty(0);
            check_wr_ptr(0);
            check_rd_ptr(0);
            $display("==============================================");
        end
    endtask
    
    task write_test(input [$clog2(`FIFO_DEPTH) : 0] last_ptr_value);
        begin
            $display("================= WRITE TEST =================");
            write_full_data();
            check_full(1);
            check_almost_full(0);
            check_wr_ptr(last_ptr_value);
            check_empty(0);
            check_almost_empty(0);
            $display("==============================================");
        end
    endtask
    
    task read_test(input [$clog2(`FIFO_DEPTH) : 0] last_ptr_value);
        begin
            $display("================= READ  TEST =================");
            read_empty_data();
            check_empty(1);
            check_almost_empty(0);
            check_rd_ptr(last_ptr_value);
            check_full(0);
            check_almost_full(0);
            $display("==============================================");
        end
    endtask
    
    task write_read_test();
        begin
            $display("============== READ/WRITE  TEST ==============");
            write_data(0);
            write_data(1);
            write_data(2);
            check_empty(0);
            check_almost_empty(0);
            check_full(0);
            check_almost_full(0);
            #30;
            read_data(0);
            read_data(1);
            check_almost_empty(1);
            read_data(2);
            check_empty(1);
            read_data(2);
            $display("==============================================");
        end
    endtask
    
    initial begin
        reset_test();
        write_test(`FIFO_DEPTH);
        read_test(`FIFO_DEPTH);
        write_test(0);
        read_test(0);
        write_read_test();
        $finish;
    end
    
endmodule
