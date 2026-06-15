`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.06.2026 20:42:40
// Design Name: 
// Module Name: uart_brg
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
module uart_brg #(
    parameter CLK_FREQ  = 50000000, // 50 MHz
    parameter BAUD_RATE = 115200    // 115200 bits/sec
)(
    input  wire clk,        
    input  wire rst_n,      
    
    output wire tick_16x    
);
    localparam MAX_COUNT = (CLK_FREQ / (BAUD_RATE * 16)) - 1;
    localparam COUNTER_WIDTH = $clog2(MAX_COUNT + 1);
    reg [COUNTER_WIDTH-1:0] tick_count;
    always @(posedge clk or negedge rst_n)
    begin
        if (!rst_n)
        begin
            tick_count <= 0;
        end 
        else 
        begin
            if (tick_count == MAX_COUNT)
                tick_count <= 0;
            else
                tick_count <= tick_count + 1;
        end
    end
    assign tick_16x = (tick_count == MAX_COUNT) ? 1'b1 : 1'b0;
endmodule
