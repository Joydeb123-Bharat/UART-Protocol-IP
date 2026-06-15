`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 07.06.2026 23:51:52
// Design Name: 
// Module Name: tb_uart_top
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

module tb_uart_top();

    // 1. Declare Testbench Signals
    reg        clk;
    reg        rst_n;
    
    reg  [7:0] tb_tx_data;
    reg        tb_tx_start;
    
    wire       tx_serial_line; // The loopback wire
    
    wire       tx_busy;
    wire       tx_done;
    
    wire [7:0] rx_data;
    wire       rx_done;
    wire       framing_error;
    wire       overrun_error;
    wire       parity_error;

    // 2. Instantiate the Top-Level Module
    uart_top #(
        .CLK_FREQ(50000000),
        .BAUD_RATE(115200)
    ) UUT (
        .clk(clk),
        .rst_n(rst_n),
        
        // LOOPBACK CONNECTION: Connect TX directly to RX
        .rx(tx_serial_line),
        .tx(tx_serial_line),
        
        .tx_data(tb_tx_data),
        .tx_start(tb_tx_start),
        .tx_busy(tx_busy),
        .tx_done(tx_done),
        
        .rx_data(rx_data),
        .rx_done(rx_done),
        
        .framing_error(framing_error),
        .overrun_error(overrun_error),
        .parity_error(parity_error)
        // Note: You may need to add the error flags to your uart_top module ports!
    );

    // 3. Generate the 50 MHz System Clock
    // 50 MHz = 20ns period (Toggle every 10ns)
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end

    // 4. Main Stimulus Process
    initial begin
        // Initialize signals
        rst_n = 0;
        tb_tx_start = 0;
        tb_tx_data = 8'h00;
        
        // Hold reset for 100ns
        #100;
        rst_n = 1;
        #100;
        // ==========================================
        // TODO: TEST CASE 1: Transmit 8'hA5
        // ==========================================
        
        // 1. Load the data 8'hA5 into tb_tx_data
        tb_tx_data <= 8'hA5;
        // 2. Pulse tb_tx_start high for at least one clock cycle (20ns), then low
        // 3. Pulse tb_tx_start high
        #20 tb_tx_start <= 1'b1;
        #20 tb_tx_start <= 1'b0;
        
        // 4. Wait for BOTH events simultaneously
        fork
            begin
                // Thread 1: Wait for TX
                @(posedge tx_done);
                $display("TX Done received!");
            end
            begin
                // Thread 2: Wait for RX
                @(posedge rx_done);
                $display("RX Done received! Checking data...");
                $display("The Value received from the rx is: %b" , rx_data);
            end
            begin
                // Thread 3: The Watchdog
                #300; 
                $display("ERROR: Simulation timed out!");
                $finish;
            end
        join// Continues as soon as ANY of these blocks finish (but we want both tx and rx)
        
        // To properly catch both without the watchdog killing it prematurely:

        #10000;
        $finish; // End simulation
    end

endmodule
