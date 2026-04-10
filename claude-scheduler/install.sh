#!/usr/bin/env bash
# install.sh — 将任务注册为 macOS launchd 定时任务
# 用法: install.sh <task-name> <cron-expr>
#
# cron-expr 格式: "HH:MM"           每天固定时间
#                 "HH:MM weekdays"   仅工作日
#                 "HH:MM interval:N" 每 N 分钟
#
# 示例:
#   install.sh daily-report "09:03"
#   install.sh daily-report "09:03 weekdays"

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASK_NAME="${1:?用法: install.sh <task-name> <time>}"
TIME_EXPR="${2:?用法: install.sh <task-name> <time>  例: \"09:03\" 或 \"09:03 weekdays\"}"

TASK_DIR="$SCRIPT_DIR/tasks/$TASK_NAME"
LABEL="com.claude.scheduler.$TASK_NAME"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"
LOG="$HOME/Library/Logs/claude-scheduler-$TASK_NAME.log"

if [[ ! -d "$TASK_DIR" ]]; then
  echo "错误: 任务不存在: $TASK_DIR"
  exit 1
fi

# 解析时间
HOUR=$(echo "$TIME_EXPR" | cut -d: -f1 | sed 's/^0//')
MINUTE=$(echo "$TIME_EXPR" | cut -d: -f2 | cut -d' ' -f1 | sed 's/^0//')
MODIFIER=$(echo "$TIME_EXPR" | awk '{print $2}')

# 卸载旧的
launchctl unload "$PLIST" 2>/dev/null || true

# 构建 StartCalendarInterval
if [[ "$MODIFIER" == "weekdays" ]]; then
  # 周一到周五各一个
  CALENDAR="<key>StartCalendarInterval</key>
    <array>$(for d in 1 2 3 4 5; do echo "
        <dict>
            <key>Weekday</key><integer>$d</integer>
            <key>Hour</key><integer>$HOUR</integer>
            <key>Minute</key><integer>$MINUTE</integer>
        </dict>"; done)
    </array>"
else
  CALENDAR="<key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key><integer>$HOUR</integer>
        <key>Minute</key><integer>$MINUTE</integer>
    </dict>"
fi

# 获取 PATH
CLAUDE_DIR=$(dirname "$(which claude 2>/dev/null || echo "/usr/local/bin/claude")")

cat > "$PLIST" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$LABEL</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$SCRIPT_DIR/scheduler.sh</string>
        <string>$TASK_NAME</string>
    </array>
    $CALENDAR
    <key>StandardOutPath</key>
    <string>$LOG</string>
    <key>StandardErrorPath</key>
    <string>$LOG</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$CLAUDE_DIR:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>$HOME</string>
    </dict>
</dict>
</plist>
EOF

launchctl load "$PLIST"
echo "已安装: $TASK_NAME → 每天 $(printf '%02d:%02d' $HOUR $MINUTE) ${MODIFIER:+($MODIFIER)}"
echo "  plist: $PLIST"
echo "  日志:  $LOG"
echo ""
echo "管理命令:"
echo "  手动触发: launchctl start $LABEL"
echo "  查看状态: launchctl list | grep $LABEL"
echo "  卸载:     $SCRIPT_DIR/uninstall.sh $TASK_NAME"
