# Verilog 开发环境使用说明

Windows 上用 VS Code 写代码，虚拟机（CentOS）里的 QuestaSim 跑仿真，波形在 VS Code 里直接看（或弹出 Questa GUI）。代码只有一份，实时同步，可直接推 GitHub。

## 环境架构

```
Windows 主机                          CentOS 虚拟机 (192.168.11.128)
─────────────────                    ──────────────────────────────
D:\代码\verilog\        ←共享文件夹→   /mnt/hgfs/verilog/
  ├─ VS Code 编辑                      QuestaSim 2021.2 仿真
  ├─ Surfer 插件看波形                  (/opt/eda/mentor/questa_sim)
  └─ git push 到 GitHub
```

- **共享文件夹**：VMware 设置 → 选项 → 共享文件夹，`D:\代码\verilog` 挂载为 `/mnt/hgfs/verilog`，两边看到的是同一份文件
- **免密 SSH**：Windows 的公钥已装入虚拟机 `~/.ssh/authorized_keys`，`ssh sut541@192.168.11.128` 直连不输密码

## 日常操作（三步）

1. **写代码**：VS Code 打开 `D:\代码\verilog` 文件夹，编辑工程子目录里的 `.v` 文件，存盘
2. **跑仿真**：按 ==**`Ctrl+Shift+B`**==（需打开着该工程里的任意文件）
   - 自动 ssh 到虚拟机 → `vlog` 编译 → `vsim -c` 仿真 → `$display` 打印显示在终端面板 → 生成 `wave.vcd`
3. **看波形**：点开该工程目录下的 `wave.vcd`（Surfer 插件渲染），改代码重跑后点 reload 刷新

需要断点、单步、查 X 态等深度调试时，改用 Questa GUI：
`Ctrl+Shift+P` → 输入 `Run Task` → 选 **"Questa 仿真 (虚拟机弹出GUI波形)"** → Questa 窗口在虚拟机桌面自动弹出，信号已加好、波形已跑完（虚拟机桌面需处于登录状态）。

## 新建一个工程（零配置）

1. 在 `D:\代码\verilog\` 下建子文件夹，如 `my_proj\`，放入设计文件和 testbench
2. 打开新工程里的任意文件按 `Ctrl+Shift+B`，完事

不需要拷脚本、不需要改名字、不需要在 testbench 里写 `$dumpfile`。仓库根目录的两个通用脚本会自动：
- 根据当前打开的文件定位工程目录（tasks.json 传入）
- 首次自动 `vlib work`
- 自动识别 `tb_` 开头的 testbench 模块作为仿真顶层（**所以 testbench 必须命名为 `module tb_xxx`**）
- 用 Questa 的 `vcd file` 命令生成 `wave.vcd`，源码保持纯净

> 唯一注意：脚本若在 Windows 端重新编辑过，报 `\r` 相关错误时在虚拟机终端跑一次：
> `sed -i 's/\r$//' /mnt/hgfs/verilog/*.sh`

## 关键文件说明

| 文件 | 作用 |
|---|---|
| `.vscode/tasks.json` | 定义两个一键任务（Ctrl+Shift+B 默认跑命令行仿真） |
| `run_sim.sh`（根目录，全工程通用） | 命令行仿真：编译 + 自动找 tb_ 模块 + 生成 wave.vcd |
| `run_gui.sh`（根目录，全工程通用） | GUI 仿真：编译 + 在虚拟机桌面弹出 Questa 波形窗口 |
| `.gitignore` | 排除 `work/`、`transcript`、`*.wlf`、`*.vcd` 等仿真产物 |

## 踩过的坑（重要）

1. **信号被优化掉（波形空、VCD 0 字节）**：Questa 的 vopt 默认剪掉内部信号。
   - ❌ 改全局 `modelsim.ini` 加 `VoptArgs = +acc` **无效**（不是合法配置项）
   - ✅ `vsim` 命令行必须带 **`-voptargs=+acc`**，两个脚本里已固定写好，别删
2. **hgfs 共享目录写大文件不可靠**：WLF 波形文件写在共享目录会损坏（"bad magic number"），`work/` 库偶发 EIO 警告。目前 VCD 方式没问题；若以后 work 库出怪错，把库挪到虚拟机本地：
   ```bash
   vlib ~/questa_libs/工程名_work && vmap work ~/questa_libs/工程名_work
   ```
3. **hgfs 目录缓存滞后**：Windows 新建的文件偶尔在虚拟机 `ls` 里看不到（报 No such file）。直接按完整路径访问一次即可刷新，如 `cat /mnt/hgfs/verilog/test/run_sim.sh`
4. **VS Code 任务必须用 cmd.exe 执行**：tasks.json 里已配置 `"shell": {"executable": "cmd.exe"}`。默认的 PowerShell 不支持 `&&` 且会抢先解析 `$()`，会报 "The token '&&' is not a valid statement separator"
5. **CentOS 7 glibc 太老**，新版 VS Code Remote-SSH Server 装不上，所以采用"本地编辑 + ssh 跑命令"方案，编辑器打开的是 Windows 本地文件
6. **GUI 任务不弹窗口（无任何报错）**：两个原因，`run_gui.sh` 里都已处理好，新工程直接拷它：
   - ssh 非交互执行时 vsim 检测到 stdin 不是终端，**静默退回批处理模式**——必须加 `-gui` 参数强制图形模式
   - X 授权文件不在 `~/.Xauthority`，而在 `/run/gdm/auth-for-用户名-随机串/database`（每次登录路径会变），脚本从桌面会话进程 `/proc/PID/environ` 里动态读取 `XAUTHORITY`
   - 前提：虚拟机桌面必须处于登录状态

## 手动命令（备用）

不用 VS Code 任务时，ssh 进虚拟机手动跑：

```bash
cd /mnt/hgfs/verilog/工程名
vlib work                # 首次需要
vlog *.v
vsim -c work.tb_模块名 -voptargs=+acc -do "run -all; quit"
```

## 上传 GitHub

```powershell
cd D:\代码\verilog
git init          # 首次
git add .
git commit -m "说明"
git push
```

仿真产物已被 `.gitignore` 排除，仓库里只有源码和脚本。


跑仿真的话：选择 *.v文件，然后按ctrl+shift+B,就可以了