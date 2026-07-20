#!/bin/bash
# GUI仿真(全工程通用): bash run_gui.sh <工程子目录>
# 在虚拟机桌面弹出 Questa 窗口, 信号已加好、波形已跑完
# 要点: -gui 强制图形模式(ssh下vsim默认进批处理); XAUTHORITY 从桌面会话动态获取
d="${1//\\//}"
cd "/mnt/hgfs/verilog/$d" || { echo "目录不存在: $d"; exit 1; }
[ -d work ] || vlib work
vlog *.v || exit 1

TB=$(grep -hoE 'module[[:space:]]+tb_[A-Za-z0-9_]*' *.v | awk '{print $2}' | head -1)
[ -z "$TB" ] && { echo "错误: 没找到 tb_ 开头的 testbench 模块"; exit 1; }
echo "==> Testbench: $TB"

pid=$(pgrep -u "$USER" -f gnome-session | head -1)
if [ -n "$pid" ]; then
    export DISPLAY=$(tr '\0' '\n' < /proc/$pid/environ | grep ^DISPLAY= | cut -d= -f2-)
    export XAUTHORITY=$(tr '\0' '\n' < /proc/$pid/environ | grep ^XAUTHORITY= | cut -d= -f2-)
fi
export DISPLAY=${DISPLAY:-:0}

nohup vsim -gui work.$TB -voptargs=+acc -do "add wave -r /*; run -all" > /dev/null 2>&1 &
echo "==> Questa GUI 已在虚拟机桌面启动 (PID $!)"
