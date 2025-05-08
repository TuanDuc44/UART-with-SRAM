set script_dir [file dirname [info script]]
set test_dir "/home/tuan/Desktop/OpenROAD/test"

# Load helper scripts
source "$test_dir/helpers.tcl"
source "$test_dir/flow_helpers.tcl"
source "$test_dir/sky130hd/sky130hd.vars"

read_lef /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130hd.tlef
read_lef /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130hd_std_cell.lef

read_liberty /home/tuan/Desktop/OpenROAD/test/sky130hd/sky130hd_tt.lib


# read netlist
set design "UART_TOP"
read_verilog UART_synth.v
link_design UART_TOP
read_sdc timing.sdc

# Set physical design constraints
set die_area {0 0 330 330}
set core_area {30 30 300 300}

# Place SRAM macro


# Power distribution network (PDN)


# Load flow script
source -echo "floorplan.tcl"


