#!/bin/bash
# 命令行仿真(全工程通用): bash run_sim.sh <工程子目录>
# 自动找 tb_ 开头的 testbench 模块; 自动生成 wave.vcd (无需在代码里写 $dumpfile)
d="${1//\\//}"
cd "/mnt/hgfs/verilog/$d" || { echo "目录不存在: $d"; exit 1; }
[ -d work ] || vlib work
vlog *.v || exit 1

TB=$(grep -hoE 'module[[:space:]]+tb_[A-Za-z0-9_]*' *.v | awk '{print $2}' | head -1)
[ -z "$TB" ] && { echo "错误: 没找到 tb_ 开头的 testbench 模块"; exit 1; }
echo "==> Testbench: $TB"

vsim -c work.$TB -voptargs=+acc -do "vcd file wave.vcd; vcd add -r /*; run -all; quit"
