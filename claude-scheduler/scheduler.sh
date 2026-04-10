#!/usr/bin/env bash
# scheduler.sh — 通用 Claude 定时任务调度器
# 用法: scheduler.sh <task-name> [date]
#
# 每个任务是 tasks/<task-name>/ 下的一个目录，包含：
#   - task.yaml   任务配置（prompt、输出路径、允许的工具等）
#   - prompt.md   发送给 Claude 的 prompt
#
# 示例: scheduler.sh daily-report
#        scheduler.sh daily-report 2026-04-10

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TASK_NAME="${1:?用法: scheduler.sh <task-name> [date]}"
DATE="${2:-$(date +%Y-%m-%d)}"
TASK_DIR="$SCRIPT_DIR/tasks/$TASK_NAME"

# ── 检查任务是否存在 ──
if [[ ! -d "$TASK_DIR" ]]; then
  echo "错误: 任务不存在: $TASK_DIR"
  echo "可用任务:"
  ls "$SCRIPT_DIR/tasks/" 2>/dev/null || echo "  (无)"
  exit 1
fi

# ── 解析 task.yaml ──
YAML="$TASK_DIR/task.yaml"
if [[ ! -f "$YAML" ]]; then
  echo "错误: 缺少配置文件: $YAML"
  exit 1
fi

# 简易 YAML 解析（避免依赖 yq）
parse_yaml() {
  local key="$1"
  grep "^${key}:" "$YAML" | sed "s/^${key}:[[:space:]]*//" | sed 's/^"//' | sed 's/"$//'
}

OUTPUT_DIR=$(parse_yaml "output_dir" | sed "s|\\\$DATE|$DATE|g; s|\\\$HOME|$HOME|g; s|~|$HOME|g")
OUTPUT_FILE=$(parse_yaml "output_file" | sed "s|\\\$DATE|$DATE|g; s|\\\$HOME|$HOME|g; s|~|$HOME|g")
ALLOWED_TOOLS=$(parse_yaml "allowed_tools")
ADD_DIRS=$(parse_yaml "add_dirs")
SKIP_IF_EXISTS=$(parse_yaml "skip_if_exists")
CLAUDE_BIN=$(parse_yaml "claude_bin")
PROMPT_FILE="$TASK_DIR/prompt.md"

# 默认值
CLAUDE_BIN="${CLAUDE_BIN:-$(which claude 2>/dev/null || echo "/usr/local/bin/claude")}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/workspace/claude-scheduler-output/$TASK_NAME}"
OUTPUT_FILE="${OUTPUT_FILE:-$OUTPUT_DIR/$DATE.md}"
ALLOWED_TOOLS="${ALLOWED_TOOLS:-Read Glob}"
SKIP_IF_EXISTS="${SKIP_IF_EXISTS:-true}"

# ── 检查 prompt ──
if [[ ! -f "$PROMPT_FILE" ]]; then
  echo "错误: 缺少 prompt 文件: $PROMPT_FILE"
  exit 1
fi

# ── 输出目录 ──
mkdir -p "$(dirname "$OUTPUT_FILE")"

# ── 跳过检查 ──
if [[ "$SKIP_IF_EXISTS" == "true" && -f "$OUTPUT_FILE" ]]; then
  echo "[$DATE][$TASK_NAME] 输出已存在，跳过: $OUTPUT_FILE"
  exit 0
fi

echo "[$DATE][$TASK_NAME] 开始执行..."

# ── 构建 claude 命令 ──
CMD=("$CLAUDE_BIN" -p "$(cat "$PROMPT_FILE")")

if [[ -n "$ALLOWED_TOOLS" ]]; then
  CMD+=(--allowedTools "$ALLOWED_TOOLS")
fi

# 处理多个 add-dir
if [[ -n "$ADD_DIRS" ]]; then
  IFS=',' read -ra DIRS <<< "$ADD_DIRS"
  for dir in "${DIRS[@]}"; do
    dir=$(echo "$dir" | xargs | sed "s|\\\$HOME|$HOME|g; s|~|$HOME|g")
    CMD+=(--add-dir "$dir")
  done
fi

# ── 执行 ──
"${CMD[@]}" > "$OUTPUT_FILE" 2>/dev/null

echo "[$DATE][$TASK_NAME] 完成: $OUTPUT_FILE"
