set power_enable_analysis true
set power_analysis_mode time_based
set power_enable_clock_scaling true

set search_path ". /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/db/  \
                   /usr/cadtool/GPDK45/gsclib045_svt_v4.4/gsclib045/verilog/ \
                   /usr/cad/synopsys/synthesis/cur/libraries/syn/ \
                   $search_path"
set target_library  "slow_vdd1v2_basicCells.db \
                     fast_vdd1v2_basicCells.db "
set link_library  "  * $target_library  \
                       dw_foundation.sldb "
read_verilog  ../../innovus/post_layout/CHIP.v
current_design  fourD_kalman_filter
link
read_sdc ../../innovus/post_layout/CHIP_layout.sdc
# read spef here 
read_parasitics ../../innovus/post_layout/CHIP_layout.gz
# read waveform
read_vcd ../../post_sim/postsim.vcd -strip_path kalman_filter_test/CHIP0

check_power
update_power
report_power  -hier > report_power_hier.rpt
report_power  > report_power_report.rpt
exit
