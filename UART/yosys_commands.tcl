# ----------------------------------------
# 1. Read RTL source
# ----------------------------------------
read_verilog UART_TOP.v
read_verilog Baud_Rate_Generator.v
read_verilog Rx_FIFO.v
read_verilog Rx_Receiver.v
read_verilog Rx_Unit.v
read_verilog Parity_Selector.v
read_verilog Tx_Unit.v
read_verilog Error_Detector.v
read_verilog Tx_FIFO.v
read_verilog Tx_Transmitter.v

# ----------------------------------------
# 2. Set Top
# ----------------------------------------
hierarchy -check -top UART_TOP

# ----------------------------------------
# 3. Transform memories into DFFs
# ----------------------------------------
memory_dff
memory_map

# ----------------------------------------
# 4. Translate processes (always, if, case...) to logic
# ----------------------------------------
proc
opt_clean
flatten    # <<< thêm flatten để gom thành 1 module duy nhất
opt

# ----------------------------------------
# 5. Generic Technology Mapping
# ----------------------------------------
techmap

# ----------------------------------------
# 6. Map DFFs to standard cells
# ----------------------------------------
dfflibmap -liberty /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib

# ----------------------------------------
# 7. Optimize Design
# ----------------------------------------
opt

# ----------------------------------------
# 8. Map combinational logic to standard cells
# ----------------------------------------
abc -liberty /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib

# ----------------------------------------
# 9. Clean up
# ----------------------------------------
opt
clean

# ----------------------------------------
# 10. Report
# ----------------------------------------
stat -liberty /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130_fd_sc_hd__tt_025C_1v80.lib

# ----------------------------------------
# 11. Write out synthesized netlist
# ----------------------------------------
write_verilog -noattr UART_synth.v

