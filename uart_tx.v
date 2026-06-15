`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 20:42:40
// Design Name: 
// Module Name: uart_tx
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
module uart_tx (
    input  wire       clk,        // System clock [cite: 10]
    input  wire       rst_n,      // Active-low asynchronous reset [cite: 10]
    input  wire       tick_16x,   // Timing reference from BRG 
    
    input  wire [7:0] tx_data,    // 8-bit payload to transmit [cite: 12]
    input  wire       tx_start,   // Pulse to begin transmission [cite: 13]
    
    output reg        tx,         // Serial output pin [cite: 11]
    output reg        tx_busy,    // TX FSM is not in IDLE [cite: 14]
    output reg        tx_done     // Pulse when STOP bit has been sent [cite: 14]
);
    
    // TODO: Define TX FSM States (IDLE, START, DATA, STOP) 
    localparam IDLE = 3'b000, START = 3'b001, DATA = 3'b010, PARITY = 3'b011, STOP1 = 3'b100, STOP2 = 3'b101;
    reg [2:0] state;
    reg [3:0]tick_count;
    reg [3:0] count;
    reg [7:0] data;
    reg parity;
    reg start_flag; 
    // To catch the start 
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
        begin
            start_flag <= 1'b0;
        end 
        else 
        begin
            if (tx_start) begin
                start_flag <= 1'b1;
            end 
            else if (state == START) 
            begin
                start_flag <= 1'b0;
            end
        end
    end
    // TODO: Implement PISO shifting logic 
    always@(posedge clk or negedge rst_n)
    begin
        if(!rst_n)
            begin
                state <= 3'b0;
                tick_count <= 4'b0;
                count <= 4'b0;
                tx <= 1'b1;
                data <= 0;
                tx_busy <= 1'b0;
                tx_done <= 1'b0;
            end
         else
            begin
                if(tick_16x)
                begin
                    if(tick_count == 4'b1111)
                        tick_count <= 4'b0;
                    else
                        tick_count <= tick_count + 1;
                    case(state)
                    IDLE: // IDLE doing nothing
                        begin
                        tx <= 1'b1;
                        tx_busy <= 1'b0;
                        tx_done <= 1'b0;
                        count <= 4'b0;
                        if(start_flag)
                        begin
                            state <= START;
                            tick_count <= 0;
                        end
                        end
                    START: // Transmission begins
                        begin
                            if(tick_count == 4'd15)
                            begin
                                state <= DATA;
                                parity <= ^tx_data;
                            end
                            tx <= 1'b0;
                            tx_busy <= 1'b1;
                            data <= tx_data;
                        end 
                    DATA: // Transmitting the data every 16th tick
                        begin
                            tx <= data[0];
                            if(tick_count == 4'd15)
                                begin   
                                    data <= {1'b0, data[7:1]};
                                    count <= count + 1;
                                    if(count == 7)
                                        state <= PARITY;
                                end
                        end
                     PARITY: // Transfering the parity
                        begin
                            tx <= parity;
                            if(tick_count == 4'd15)
                            begin
                                tx <= parity;
                                state <= STOP1;
                            end
                        end
                     STOP1: // First Stop bit
                        begin
                            tx<= 1'b1;
                            if(tick_count == 4'd15)
                            begin
                                state <= STOP2;
                            end
                        end
                     STOP2: // Second Stop bit
                        begin
                            tx <= 1'b1;
                            if(tick_count == 4'd15)
                            begin
                                
                                state <= IDLE;
                                tx_done <= 1'b1;
                                tx_busy <= 1'b0;
                            end
                        end
                 endcase
                end
            end 
    end
endmodule