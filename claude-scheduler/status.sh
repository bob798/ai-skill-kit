#!/usr/bin/env bash
# status.sh — 查看所有已注册的 Claude 定时任务状态
# 用法: status.sh

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "=== Claude Scheduler 任务状态 ==="
echo ""

# 列出所有任务目录
for task_dir in "$SCRIPT_DIR"/tasks/*/; do
  [[ -d "$task_dir" ]] || continue
  task_name=$(basename "$task_dir")
  label="com.claude.scheduler.$task_name"
  plist="$HOME/Library/LaunchAgents/$label.plist"

  if [[ -f "$plist" ]]; then
    status=$(launchctl list 2>/dev/null | grep "$label" | awk '{print "exit=" $2}')
    echo "  [已安装] $task_name  $status"
  else
    echo "  [未安装] $task_name"
  fi
done

# 检查旧格式的任务（com.claude.daily-report 等）
for plist in "$HOME"/Library/LaunchAgents/com.claude.*.plist; do
  [[ -f "$plist" ]] || continue
  label=$(basename "$plist" .plist)
  [[ "$label" == com.claude.scheduler.* ]] && continue
  echo "  [旧格式] $label → 建议迁移到 claude-scheduler"
done

echo ""
echo "管理: install.sh / uninstall.sh / scheduler.sh"
