# Claude Scheduler

基于 macOS launchd + `claude -p` 的定时任务调度器。让 Claude Code 在后台自动执行重复性任务，无需保持 REPL 打开。

## 为什么需要这个？

Claude Code 内置的 `CronCreate` 依赖 REPL 保持运行，关闭终端即失效。Claude Scheduler 将调度权下沉到操作系统层：

| | CronCreate | Claude Scheduler |
|---|---|---|
| 依赖 REPL | 是 | 否 |
| 电脑休眠后 | 停止 | 唤醒后补执行 |
| 最长有效期 | 7 天 | 永久 |
| 任务管理 | 内存中 | 文件 + launchd |

## 工作原理

```
macOS launchd (系统守护进程)
    │ 按 cron 时间触发
    ▼
scheduler.sh <task-name>
    │ 读取 tasks/<task-name>/task.yaml + prompt.md
    ▼
claude -p "<prompt>" --allowedTools "..." --add-dir "..."
    │ headless 模式执行，无需交互
    ▼
输出到指定的 Markdown 文件
```

## 快速开始

### 1. 安装内置的 daily-report 任务

```bash
# 每天 9:03 自动生成日报
./install.sh daily-report "09:03"

# 仅工作日
./install.sh daily-report "09:03 weekdays"
```

### 2. 手动触发测试

```bash
# 直接运行
./scheduler.sh daily-report

# 通过 launchd 触发
launchctl start com.claude.scheduler.daily-report
```

### 3. 查看状态

```bash
./status.sh
```

### 4. 卸载

```bash
./uninstall.sh daily-report
```

## 创建自定义任务

### 目录结构

```
claude-scheduler/
├── scheduler.sh          # 通用调度脚本
├── install.sh            # 注册到 launchd
├── uninstall.sh          # 从 launchd 移除
├── status.sh             # 查看所有任务状态
└── tasks/
    └── <task-name>/
        ├── task.yaml     # 任务配置
        └── prompt.md     # Claude prompt
```

### task.yaml 配置项

```yaml
# 输出目录和文件（支持 $DATE、$HOME、~ 变量）
output_dir: ~/workspace/daily-reports
output_file: ~/workspace/daily-reports/$DATE.md

# 授权 Claude 使用的工具
allowed_tools: Bash(git:*) Read Glob

# 授权 Claude 访问的目录（逗号分隔）
add_dirs: ~/workspace,~/lifelog

# 输出文件已存在时是否跳过（默认 true）
skip_if_exists: true

# claude 可执行文件路径（默认自动检测）
claude_bin: /usr/local/bin/claude
```

### 示例：创建周报任务

```bash
mkdir -p tasks/weekly-summary
```

`tasks/weekly-summary/task.yaml`:
```yaml
output_dir: ~/workspace/weekly-reports
output_file: ~/workspace/weekly-reports/$DATE.md
allowed_tools: Bash(git:*) Read Glob
add_dirs: ~/workspace,~/lifelog
skip_if_exists: true
```

`tasks/weekly-summary/prompt.md`:
```markdown
汇总本周的 git 活动和 lifelog，生成周报...
```

安装：
```bash
# 每周五 17:00
./install.sh weekly-summary "17:00 weekdays"
```

## 管理命令

```bash
# 查看所有任务
./status.sh

# 手动运行任意任务
./scheduler.sh <task-name>
./scheduler.sh <task-name> 2026-04-10  # 指定日期

# 安装/卸载
./install.sh <task-name> "HH:MM"
./install.sh <task-name> "HH:MM weekdays"
./uninstall.sh <task-name>

# 查看日志
cat ~/Library/Logs/claude-scheduler-<task-name>.log

# launchd 直接操作
launchctl start com.claude.scheduler.<task-name>
launchctl list | grep claude.scheduler
```

## 限制

- **电脑必须开机**：关机期间任务不会执行（休眠可以，唤醒后补执行）
- **API 消耗**：每次执行消耗 Claude API token
- **仅 macOS**：依赖 launchd，Linux 需改用 systemd/cron
- **无网络回调**：不支持 webhook 通知，结果仅写入本地文件

## 迁移旧任务

如果之前手动创建了 `com.claude.daily-report` 等 plist：

```bash
# 卸载旧的
launchctl unload ~/Library/LaunchAgents/com.claude.daily-report.plist
rm ~/Library/LaunchAgents/com.claude.daily-report.plist

# 用新工具重新安装
./install.sh daily-report "09:03"
```
