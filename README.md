Markdown



# 📡 Fully Parameterized UART Transceiver IP Core (Verilog)



![Language](https://img.shields.io/badge/Language-Verilog--2001-blue.svg)

![Status](https://img.shields.io/badge/Status-Verified-success.svg)

![Architecture](https://img.shields.io/badge/Architecture-CDC--Hardened-orange.svg)## 📌 Overview

This repository contains a robust, synthesizable Universal Asynchronous Receiver-Transmitter (UART) intellectual property (IP) core written in standard Verilog. Designed from the ground up to handle noisy physical-layer asynchronous serial communication, this transceiver implements rigorous Clock Domain Crossing (CDC) protections, phase-aligned oversampling, and temporal majority voting to guarantee data integrity.



---## ✨ Key Architectural Features* **Fully Parameterized Design:** Seamlessly adapts to any system clock frequency (`CLK_FREQ`) and target baud rate (`BAUD_RATE`) via top-level parameter overriding.* **CDC Hardened Receiver:** Employs a 2-stage D-Flip-Flop synchronizer to quarantine asynchronous RX inputs running at the system clock speed, mitigating metastability risks before signals enter the primary FSM.* **Phase-Aligned 16x Oversampling:** The receiver detects the exact falling edge of the Start bit and executes a hard-reset of its internal timing counters. This guarantees perfect phase alignment with the remote transmitter's clock domain.* **Temporal Majority Voting:** Rather than relying on a single clock-edge sample, the receiver samples the physical line temporally at the 7th, 8th, and 9th ticks of the oversampled bit period. It performs a boolean majority vote to reject high-frequency electromagnetic noise.* **Comprehensive Error Diagnostics:** Real-time hardware flagging for Parity mismatches, Framing errors (missing or dropped stop bits), and Overrun conditions (host processor latency).



---## 🏗️ RTL Design Details & Module Hierarchy



The RTL code is modularized into three core components wrapped by a top-level interface.```text

uart_top.v (Top-Level Wrapper)

 │

 ├── uart_brg.v (Baud Rate Generator)

 ├── uart_tx.v  (Transmitter FSM)

 └── uart_rx.v  (Receiver FSM)

1. Baud Rate Generator (uart_brg.v)

A parameter-driven free-running counter that divides the main system clock to generate a continuous tick_16x pulse. This internal heartbeat drives both the TX and RX state machines at exactly 16 times the desired transmission speed, allowing for precise sub-bit timing without the use of multiple clock domains.

2. Transmitter (uart_tx.v)

A Parallel-In-Serial-Out (PISO) Finite State Machine triggered by a synchronous tx_start pulse.

Operates in a strict 6-state FSM: IDLE ➔ START ➔ DATA ➔ PARITY ➔ STOP1 ➔ STOP2.

Automatically calculates and appends an Even Parity bit.

Enforces two strict stop-bits to guarantee inter-frame spacing and give the receiver ample recovery time.

3. Receiver (uart_rx.v)

A Serial-In-Parallel-Out (SIPO) Finite State Machine that actively hunts for Start bits.

Extracts the payload Least Significant Bit (LSB) first using non-blocking right-shift registers.

Computes expected parity from the received payload and compares it against the transmitted parity bit.

Asserts rx_done alongside the reconstructed 8-bit parallel payload for precisely one clock cycle upon successful reception, acting as an interrupt for a master processor.

🔌 Top-Level Interface (uart_top.v)

Port NameDirectionWidthDescriptionclkInput1Master system clock (Default 50 MHz).rst_nInput1Active-low asynchronous reset.rxInput1Asynchronous physical serial receive line.txOutput1Physical serial transmit line.tx_dataInput8Parallel payload to be transmitted.tx_startInput11-cycle pulse to trigger transmission.tx_busyOutput1High while TX FSM is actively shifting data.tx_doneOutput11-cycle pulse indicating transmission complete.rx_dataOutput8Reconstructed parallel payload.rx_doneOutput11-cycle pulse indicating a valid byte is ready to read.framing_errorOutput1Flags if the line drops low during the expected Stop bit periods.overrun_errorOutput1Flags if a new byte arrives before the previous rx_done was handled.parity_errorOutput1Flags if the calculated payload parity mismatches the received parity bit.

🧪 Verification Strategy (tb_uart_top.v)

The design includes a professional-grade RTL testbench utilizing a Full-Duplex Loopback methodology.

Advanced Simulation Features:

Physical Loopback: The tx output port is physically hardwired to the rx input port within the test harness (.rx(tx_serial_line), .tx(tx_serial_line)) to simulate a flawless transmission channel.

Race-Condition Mitigation: Uses standard Verilog fork...join constructs to monitor simultaneous TX and RX completion flags. This specifically handles the inherent latency difference between the receiver finishing data extraction (mid-Stop bit) and the transmitter finishing its double stop-bits.

Watchdog Timers: Incorporates a hard simulation timeout (#1000000; $finish;) to catch silent FSM failures or missed state transitions. This prevents "zombie simulations" where the simulator hangs indefinitely during automated regressions.

🚀 Getting Started (How to Simulate)

This core is written in standard Verilog-2001 and is synthesis-ready. It is compatible with all major EDA tools including Xilinx Vivado, Intel Quartus, ModelSim, and Icarus Verilog.

Clone the repository:

Bash



git clone [https://github.com/YourUsername/UART-Protocol-IP.git](https://github.com/YourUsername/UART-Protocol-IP.git)

Add all .v files in the /rtl directory to your project's design sources.

Add tb_uart_top.v from the /sim directory to your simulation sources.

Set tb_uart_top as the top module for simulation.

Run the behavioral simulation. You should observe the hex payload (8'hA5) successfully serialize, transmit, reconstruct, and trigger the $display verification message in the TCL/simulation console.

🗺️ Future Roadmap

[ ] Dual-Clock FIFO Integration: Add an asynchronous FIFO buffer on the RX output to completely eliminate overrun risks during high CPU/Bus latency.

[ ] AXI4-Lite Wrapper: Add an AXI memory-mapped wrapper to allow seamless integration into ARM Cortex (Zynq) or RISC-V SoC architectures.

[ ] Dynamic Configuration Registers: Allow software-selectable Baud Rates, Parity (Odd/Even/None), and Stop Bits (1 or 2) at runtime.

Designed for robust hardware communication.



Give this entire thing to me in markdown format. 
