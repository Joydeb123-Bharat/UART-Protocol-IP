# 📡 Fully Parameterized UART Transceiver IP Core (Verilog)

![Language](https://img.shields.io/badge/Language-Verilog_2001-blue.svg)
![Simulation](https://img.shields.io/badge/Simulation-Tested-success.svg)
![Status](https://img.shields.io/badge/Status-Complete-green.svg)

## 📌 1. Project Overview
This repository contains a robust, synthesizable Universal Asynchronous Receiver-Transmitter (UART) intellectual property (IP) core written in standard Verilog. It is designed from the ground up to handle noisy physical-layer asynchronous serial communication. 

Unlike basic UART implementations, this core implements rigorous **Clock Domain Crossing (CDC) protections**, **phase-aligned oversampling**, and **temporal majority voting** to guarantee data integrity in real-world FPGA/ASIC deployments.

---

## ✨ 2. Key Architectural Features

* **Fully Parameterized:** Seamlessly adapts to any system clock frequency (`CLK_FREQ`) and target baud rate (`BAUD_RATE`) via top-level parameter overriding. No hardcoded timing values.
* **CDC Hardened:** The receiver employs a high-speed 2-stage D-Flip-Flop synchronizer to quarantine asynchronous RX inputs, mitigating metastability risks before physical signals enter the primary FSM.
* **16x Phase-Aligned Oversampling:** The receiver detects the exact falling edge of the Start bit and executes a hard-reset of its internal timing counters, guaranteeing perfect phase alignment with the remote transmitter.
* **Temporal Majority Voting:** Rather than relying on a single clock-edge sample, the receiver samples the physical line temporally at the 7th, 8th, and 9th ticks of the oversampled bit period, performing a boolean majority vote to reject high-frequency electromagnetic noise.
* **Comprehensive Error Diagnostics:** Real-time hardware flagging for Parity mismatches, Framing errors (missing stop bits), and Overrun conditions (host processor latency).
* **Double Stop-Bit Generation:** Enforces strict two-stop-bit spacing during transmission to prevent frame collisions.

---

## 🏗️ 3. Module Hierarchy & Description

The IP core is strictly modularised to separate clock generation, transmission, and reception logic.

```text
uart_top.v (Top-Level Wrapper)
 ├── uart_brg.v (Baud Rate Generator)
 ├── uart_tx.v  (Transmitter FSM)
 └── uart_rx.v  (Receiver FSM)
