# Clock signal
set_property PACKAGE_PIN AC19 [get_ports clk]
set_property IOSTANDARD LVCMOS33 [get_ports clk]

# 7-segment display segment pins (seg1, seg2)
set_property PACKAGE_PIN C4 [get_ports {seg[7]}]
set_property PACKAGE_PIN A2 [get_ports {seg[6]}]
set_property PACKAGE_PIN D4 [get_ports {seg[5]}]
set_property PACKAGE_PIN E5 [get_ports {seg[4]}]
set_property PACKAGE_PIN B4 [get_ports {seg[3]}]
set_property PACKAGE_PIN B2 [get_ports {seg[2]}]
set_property PACKAGE_PIN E6 [get_ports {seg[1]}]
set_property PACKAGE_PIN C3 [get_ports {seg[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[7]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[6]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[5]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {seg[0]}]

# 7-segment display digit select pins (duan)
set_property PACKAGE_PIN D3 [get_ports {digit_select[0]}]
set_property PACKAGE_PIN D25 [get_ports {digit_select[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {digit_select[1]}]

# Reset signal (rst)
set_property PACKAGE_PIN AC21 [get_ports reset]
set_property IOSTANDARD LVCMOS33 [get_ports reset]

# Button input signal (but)
set_property PACKAGE_PIN AD24 [get_ports button]
set_property IOSTANDARD LVCMOS33 [get_ports button]
