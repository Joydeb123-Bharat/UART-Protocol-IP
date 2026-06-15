`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 20:42:40
// Design Name: 
// Module Name: uart_top
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
`timescale 1ns / 1ps

module uart_top #(
    parameter CLK_FREQ  = 50000000, // Default 50 MHz
    parameter BAUD_RATE = 115200    // Default 115200 baud
)(
    // Global Signals
    input  wire       clk,          // System clock
    input  wire       rst_n,        // Active-low asynchronous reset

    // Physical Serial Interfaces
    input  wire       rx,           // The asynchronous serial input line
    output wire       tx,           // The serial output line

    // TX User/Processor Interface
    input  wire [7:0] tx_data,      // 8-bit data payload to be transmitted
    input  wire       tx_start,     // Pulse to begin transmission
    output wire       tx_busy,      // High when TX is actively transmitting
    output wire       tx_done,      // Pulse when transmission completes

    // RX User/Processor Interface
    output wire [7:0] rx_data,      // 8-bit data payload successfully received
    output wire       rx_done,      // Pulse indicating a new byte is ready to read
    
    // RX Status & Error Flags
    output wire       framing_error, // Stop bit(s) not detected properly
    output wire       overrun_error, // New data arrived before previous was handled
    output wire       parity_error   // Parity bit mismatch
);

    wire internal_tick_16x; 
    // 1. Baud Rate Generator
    // Note: We use #(.PARAM(PARAM)) to pass the top-level parameters down
    uart_brg #(
        .CLK_FREQ (CLK_FREQ), 
        .BAUD_RATE(BAUD_RATE)
    ) BRG_inst (
        .clk      (clk), 
        .rst_n    (rst_n), 
        .tick_16x (internal_tick_16x)  // Connect to the internal wire
    );

    // 2. Transmitter Module
    uart_tx TX_inst (
        .clk      (clk), 
        .rst_n    (rst_n), 
        .tick_16x (internal_tick_16x), // Connect to the internal wire
        
        .tx_data  (tx_data), 
        .tx_start (tx_start), 
        
        .tx       (tx), 
        .tx_busy  (tx_busy), 
        .tx_done  (tx_done)
    );

    // 3. Receiver Module
    uart_rx RX_inst (
        .clk            (clk), 
        .rst_n          (rst_n), 
        .tick_16x       (internal_tick_16x), // Connect to the internal wire
        .rx             (rx), 
        
        .rx_data        (rx_data), 
        .rx_done        (rx_done), 
        
        .framing_error  (framing_error), 
        .overrun_error  (overrun_error), 
        .parity_error   (parity_error)
    );

endmodule