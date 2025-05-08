# 1. Clock definition
create_clock -name sys_clk -period 10 [get_ports SysClk]

# 2. Input delays
set_input_delay 2 -clock sys_clk [get_ports {Data_in[*] baud_selector[*] parity_sel start_Tx Receive}]

# 3. Output delays
set_output_delay 2 -clock sys_clk [get_ports {Data_out[*] Parity_Error Frame_Error Overflow}]

# 4. Reset (false path)
set_false_path -from [get_ports rst]
