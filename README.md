# UART Design and Verification

Comprehensive UART RTL design and verification using Verilog HDL  
Self-checking verification environment with high functional and coverage closure

---

## Overview

This project implements and verifies a parameterized Micro UART
(Universal Asynchronous Receiver Transmitter) using Verilog HDL.

The UART design enables asynchronous serial communication between
devices without requiring a shared clock signal.

The design consists of:
- Baud Rate Generator
- UART Transmitter
- UART Receiver
- Top-Level UART Wrapper

A self-checking testbench is used to automatically validate UART
transmission and reception by comparing DUT outputs against
expected reference behavior.

The design and verification were performed using:
- Vivado
- Questa SIM

---

## ⚙️ UART Features

### UART Communication
- UART Serial Transmission
- UART Serial Reception
- Start-bit detection
- Stop-bit validation
- Continuous serial communication
- Back-to-back frame transfer support

### Transmission Features
- 8-bit parallel-to-serial conversion
- Start bit generation
- Stop bit generation
- LSB-first transmission
- Busy indication using xmit_active

### Receiver Features
- Serial-to-parallel reconstruction
- Mid-baud-period sampling
- Receive ready indication
- Receiver busy indication
- Frame synchronization

### Baud Generator
- Programmable baud-rate generation
- Clock divider based baud clock
- Shared baud synchronization between TX and RX

---

## Input Signals

| Signal | Width | Description |
|--------|--------|-------------|
| sys_clk | 1-bit | System clock |
| sys_rst | 1-bit | Active-high synchronous reset |
| xmit_h | 1-bit | Transmission enable |
| xmit_data_h[7:0] | 8-bit | Parallel transmit data |
| clk_freq[31:0] | 32-bit | Baud clock configuration register |

---

## Output Signals

| Signal | Width | Description |
|--------|--------|-------------|
| uart_xmit_data_h | 1-bit | UART TX serial output |
| xmit_done_h | 1-bit | Transmission complete pulse |
| xmit_active | 1-bit | Transmitter busy flag |
| rec_data_h[7:0] | 8-bit | Parallel received data |
| rec_ready_h | 1-bit | Receive data valid pulse |
| rec_busy | 1-bit | Receiver busy flag |
| baud_op_clk | 1-bit | Generated baud clock |

---

## Verification Methodology

### Self-Checking Testbench

The UART verification environment follows:

Stimulus → Driver → Monitor → Comparator → Scoreboard

### Verification Components
- Clock Generator
- Reset Generator
- UART Driver
- UART DUT
- Monitor
- Comparator
- Scoreboard
- Coverage Collection

### Comparator Functionality
The comparator checks:
- rec_data_h == xmit_data_h

PASS/FAIL results are generated automatically for every test case.

---

## Signals Verified

### Transmission Signals
- uart_xmit_data_h
- xmit_done_h
- xmit_active

### Reception Signals
- rec_data_h
- rec_ready_h
- rec_busy

### Timing Signals
- baud_op_clk
- Start-bit timing
- Stop-bit timing
- Busy/ready sequencing

---

# Coverage Report

The UART design was verified using Questa SIM coverage analysis
with the following results:

| Coverage Type | Coverage |
|-----------------------------|-----------|
| Overall Coverage | 96.61% |
| Statement Coverage | 93.26% |
| Branch Coverage | 93.18% |
| FEC Expression Coverage | 100.00% |
| Toggle Coverage | 96.62% |
| FSM State Coverage | 100.00% |
| FSM Transition Coverage | 100.00% |

The high overall coverage demonstrates comprehensive verification
of UART functionality including transmission, reception,
baud synchronization, reset behavior, and FSM sequencing.

Minor uncovered coverage corresponds mainly to timing-dependent
internal counter conditions and rare edge-case branches.

---

# Test Coverage

The verification environment includes extensive directed and
protocol-level testing.

## Functional Testing
- UART transmission
- UART reception
- Start-bit detection
- Stop-bit validation
- Busy and ready flag generation

## Boundary Testing
- 0x00
- 0xFF
- 0xAA
- 0x55

## Timing Verification
- Baud-rate synchronization
- Frame completion timing
- Mid-baud sampling accuracy
- Busy/ready pulse timing

## Reset Testing
- Reset during transmission
- Reset during idle state
- Register initialization verification

## Continuous Communication Testing
- Back-to-back frame transfers
- Continuous multi-byte communication
- Consecutive UART frames without gaps

---

# Waveform Verification

Waveform analysis confirmed:
- Correct UART frame generation
- Proper start and stop bit timing
- Accurate serial-to-parallel reconstruction
- Correct transmitter and receiver FSM behavior
- Reliable baud synchronization
- Successful back-to-back communication

Nine consecutive UART frames were successfully transmitted
and received during simulation without frame corruption.

---

# Results Summary

| Operation | Status |
|--------------------------------|-----------|
| UART Serial Transmission | PASS |
| UART Serial Reception | PASS |
| Start-Bit Detection | PASS |
| Stop-Bit Validation | PASS |
| Baud-Rate Synchronization | PASS |
| Reset Handling | PASS |
| Busy Flag Generation | PASS |
| Ready Flag Generation | PASS |
| Back-to-Back Transfers | PASS |
| Continuous Communication | PASS |

The UART design was functionally verified successfully across
all tested scenarios.

---

# Tools Used

## Vivado (Xilinx/AMD)
- RTL simulation
- Synthesis checking
- Waveform debugging

## Questa SIM (Siemens EDA)
- Functional verification
- Coverage analysis
- FSM coverage
- HTML coverage report generation

---

# Future Improvements

- Add parity-bit support
- Add UART error detection
- Implement TX/RX FIFO buffers
- Support configurable stop bits
- Add 7-bit and 9-bit data modes
- Implement RTS/CTS flow control
- Develop UVM-based verification environment
- FPGA hardware implementation and testing
- Programmable baud-rate selection

---
