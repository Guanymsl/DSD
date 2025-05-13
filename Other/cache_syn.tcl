sh mkdir -p Netlist
sh mkdir -p Report

#read_file -format verilog cache_2way.v
read_file -format verilog cache_dm.v

set DESIGN "cache_dm"

source cache_syn.sdc

compile_ultra -no_autoungroup

#####################################################

report_area         -hierarchy
report_timing       -delay min  -max_path 5
report_timing       -delay max  -max_path 5
report_area         -hierarchy              > ./Report/${DESIGN}_syn.area
report_timing       -delay min  -max_path 5 > ./Report/${DESIGN}_syn.timing_min
report_timing       -delay max  -max_path 5 > ./Report/${DESIGN}_syn.timing_max

write_sdf   -version 2.1                ./Netlist/${DESIGN}_syn.sdf
write   -format verilog -hier -output ./Netlist/${DESIGN}_syn.v
write   -format ddc     -hier -output ./Netlist/${DESIGN}_syn.ddc






