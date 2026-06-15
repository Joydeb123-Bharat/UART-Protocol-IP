`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 20:42:40
// Design Name: 
// Module Name: uart_rx
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
module uart_rx (
    input  wire       clk,             // System clock [cite: 10]
    input  wire       rst_n,           // Active-low asynchronous reset [cite: 10]
    input  wire       tick_16x,        // Timing reference from BRG 
    input  wire       rx,              // Asynchronous serial input [cite: 11]
    
    output reg  [7:0] rx_data,         // Reconstructed parallel data [cite: 15]
    output reg        rx_done,         // Pulse when new, valid byte is ready [cite: 15]
    
    output reg        framing_error,   // Stop bit not detected properly 
    output reg        overrun_error,    // New data arrived before previous was handled 
    output reg        parity_error     // Parity bit mismatch
);  
    // TODO: Implement 2-stage (or 3-stage) Synchronizer for `rx` [cite: 110]
    reg meta, rec, parity; 
    // TODO: Define RX FSM States (IDLE, START_DETECT, DATA_SAMPLE, STOP_DETECT) [cite: 30]
    localparam IDLE = 2'b00, START_DETECT = 2'b01, DATA_SAMPLE = 2'b10, STOP_DETECT = 2'b11;
    // TODO: Implement 16x tick counting to find bit center [cite: 99]
    reg [1:0] state;
    reg [3:0] count;
    reg [7:0] data_rx;
    reg [3:0] tick_count;
    // TODO: Implement Majority Voting logic (optional but recommended) [cite: 101, 102]
    reg tick_7, tick_8, tick_9;
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
        begin
            rx_data <= 8'b0;
            rx_done <= 1'b0;
            framing_error <= 1'b0;
            overrun_error <= 1'b0;
            parity_error <= 1'b0;
            parity <= 1'b0;
            state <= 2'b0;
            count <= 4'b0;
            data_rx <= 8'b0;
            tick_count <= 4'b0;
            meta <= 1'b1;
            rec <= 1'b1;
            tick_7 <= 1'b0;
            tick_8 <= 1'b0;
            tick_9 <= 1'b0;
        end
        else
        begin
            meta <= rx;
            rec <= meta;
            if(tick_16x)
            begin
                if(tick_count == 4'd15)
                    tick_count <= 4'b0;
                else
                    if(state != IDLE)
                    tick_count <= tick_count + 1;
                
                if(tick_count == 7)
                      tick_7 <= rec;
                else if(tick_count == 8)
                    tick_8 <= rec;
                else if(tick_count == 9)
                    tick_9 <= rec;
                case(state)
                    IDLE: // The system is idle
                    begin
                        parity <= 1'b0;
                        count <= 3'b0;
                        data_rx <= 8'b0;
                        rx_done <= 1'b0;
                        tick_count <= 4'b0;
                        tick_7 <= 1'b0;
                        tick_8 <= 1'b0;
                        tick_9 <= 1'b0;
                        if(rec == 1'b0)
                            state <= START_DETECT;
                    end
                    START_DETECT: //The detection starts
                    begin
                         if(tick_count == 10)
                         begin
                            if(!((tick_7 & tick_8)|(tick_8 & tick_9)|(tick_9 & tick_7)))
                            state <= DATA_SAMPLE;
                            else
                            state <= IDLE;
                         end
                    end
                    DATA_SAMPLE: //Sampleing the data at every 7th, 8th and 9th tick
                    begin
                         if(tick_count == 10 && count < 8)
                         begin
                            data_rx <= {((tick_7 & tick_8)|(tick_8 & tick_9)|(tick_9 & tick_7)), data_rx[7:1]};
                            count <= count + 1;
                         end
                         else if(tick_count == 10 && count == 8)
                         begin
                            parity <= (tick_7 & tick_8)|(tick_8 & tick_9)|(tick_9 & tick_7);
                            count <= count + 1;
                            state <= STOP_DETECT;
                         end
                    end
                    STOP_DETECT: //Detecting the stop bit
                        begin
                            if(tick_count == 10 && (count == 9 || count == 10)) // STOP bits detection
                            begin
                                if(((tick_7 & tick_8)|(tick_8 & tick_9)|(tick_9 & tick_7)))
                                    count <= count + 1;
                                else
                                    framing_error <= 1'b1;
                            end
                            else if (count == 11 && !rx_done)
                            begin
                                 overrun_error <= 1'b1;
                                 state <= IDLE;
                            end                                 
                            if(count == 11)
                            begin
                                state <= IDLE;
                                rx_done <= 1'b1;
                                rx_data <= data_rx;
                                parity_error <= ^{parity,data_rx}; 
                            end
                        end
                 endcase
            end
        end
    end
endmodule