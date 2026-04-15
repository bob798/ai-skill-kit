#!/usr/bin/env bash
# uninstall.sh — 卸载 launchd 定时任务
# 用法: uninstall.sh <task-name>

set -euo pipefail

TASK_NAME="${1:?用法: uninstall.sh <task-name>}"
LABEL="com.claude.scheduler.$TASK_NAME"
PLIST="$HOME/Library/LaunchAgents/$LABEL.plist"

if [[ ! -f "$PLIST" ]]; then
  echo "任务未安装: $TASK_NAME"
  exit 1
fi

launchctl unload "$PLIST" 2>/dev/null || true
rm -f "$PLIST"
echo "已卸载: $TASK_NAME"
