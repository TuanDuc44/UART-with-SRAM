# UART-with-SRAM
Connected custom SRAM with UART 

# Overview
The Universal Asynchronous Receiver/Transmitter (UART) is a popular communication protocol used for serial communication between devices. It allows for full-duplex data exchange, meaning data can be sent and received simultaneously. UART is commonly used in embedded systems, microcontrollers, and FPGA designs for communication between hardware and peripheral devices.

This repository contains the Verilog implementation of a UART protocol with FIFOs for handling data transmission and reception. The design includes features such as configurable baud rates, parity error detection, and FIFO buffers for more efficient data handling.

# UART Structure

Every signal in the structure that is outside the UART TOP boundary will be automatically driven by the testbench or by an external system.

# Work Idea:
The baud generator takes the system clock and generates the baud clock according to the baud rate selected using the baud select signal. The baud clock then runs the rest of the UART components.
When passing bytes to the tx_transmitter, it sends them at the positive edge to the tx_fifo for storage. It continues this process until the tx_fifo is full. At that point, additional input data is ignored, or if the tx_fifo is busy, it waits.
The parity selector takes the data input and generates a parity bit (even or odd, based on selection). The parity bit is then sent to the tx_fifo.
The tx_fifo takes the 9 bits (8 data bits + 1 parity bit), serializes them bit by bit, and transmits the bits to the rx_fifo.
The rx_fifo receives the serialized bits, checks for errors such as Frame Error, Overrun Error, and Break Error, and stores the new 12 bits.
When a receive order is initiated, the rx receiver displays only the first 9 bits (8 data bits + 1 parity bit), excluding the error bits.
The error detector shows only the 3 error bits (Frame Error, Overrun Error, and Break Error).

## Signals

| **Primary Signal**         | **Port** | **Description**                                                                                   |
|--------------------|---------------|---------------------------------------------------------------------------------------------------|
| **SysClk**            | Input         | System Clock (driven from outside).                                                                               |
| **rst**            | Input         | Resets the UART logic and FIFOs.                                                                                |
| **Baud_clk**       | Internal      | Baud rate clock                                                            |
| **Data_in**        | Input | Input data to the UART.                                                         |
| **baud_selector**     | Input         | Selects the Baud rate.                                                  |
| **parity_sel**  | Input         | Choses parity bit to be Even or Odd.                                                               |
| **start_Tx**    | Input         | To start the transaction between the two FIFOs.                                   |
| **TxFF**        | Internal | Signals when Tx FIFO is Full.                                                          |
| **Receive**          | Input         | order to receive data from external system.                                                                   |
| **Rx_ready**       | Internal        | Flag from Rx_FIFO to state that the FIFO is ready for receiving from Tx_FIFO.                                        |
| **Serialized Bits**       | Internal        | serial data from the Tx_FIFO (PISO).                                |
| **RxFE**   | Internal        | Signals when Rx FIFO is empty.                          |
| **Data_out**  | Output      | Data out from the UART
| **Parity Error**   | Output        | Indicates a parity mismatch when enabled.                                                          |
| **Frame Error**    | Output        | Raised when the received data frame does not match the expected format (start, stop, data bits).    |
| **Overflow**       | Output        | Raised if the FIFO buffer overflows before the data can be read.                                   |

---
