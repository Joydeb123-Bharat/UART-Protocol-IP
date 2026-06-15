# Fully Parameterized UART Transceiver IP Core (Verilog)

## 📌 Overview
This repository contains a robust, synthesizable Universal Asynchronous Receiver-Transmitter (UART) intellectual property (IP) core written in standard Verilog. Designed from the ground up to handle noisy physical-layer asynchronous serial communication, this transceiver implements rigorous Clock Domain Crossing (CDC) protections, phase-aligned oversampling, and temporal majority voting to guarantee data integrity.

## ✨ Key Architectural Features
* **Fully Parameterized:** Seamlessly adapts to any system clock frequency (`CLK_FREQ`) and target baud rate (`BAUD_RATE`) via top-level parameter overriding.
* **CDC Hardened:** The receiver employs a 2-stage D-Flip-Flop synchronizer to quarantine asynchronous RX inputs, mitigating metastability risks before signals enter the primary FSM.
* **16x Phase-Aligned Oversampling:** The receiver detects the exact falling edge of the Start bit and executes a hard-reset of its internal timing counters, guaranteeing perfect phase alignment with the remote transmitter.
* **Temporal Majority Voting:** Rather than relying on a single clock-edge sample, the receiver samples the physical line temporally at the 7th, 8th, and 9th ticks of the oversampled bit period, performing a boolean majority vote to reject high-frequency electromagnetic noise.
* **Comprehensive Error Diagnostics:** Real-time hardware flagging for Parity mismatches, Framing errors (missing stop bits), and Overrun conditions (host processor latency).

---

## 🏗️ Module Hierarchy & Architecture

```text
uart_top.v (Top-Level Wrapper)
 ├── uart_brg.v (Baud Rate Generator)
 ├── uart_tx.v  (Transmitter FSM)
 └── uart_rx.v  (Receiver FSM)
