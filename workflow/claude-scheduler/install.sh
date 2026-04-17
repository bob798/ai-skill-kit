#!/usr/bin/env bash
# install.sh — DEPRECATED shim.
# Use `scheduler add <name> --schedule "..."` instead.
#
# This script previously accepted:
#   install.sh <task-name> "HH:MM"
#   install.sh <task-name> "HH:MM weekdays"
#
# It now translates to the new `scheduler add` form and forwards. Existing task
# directories under tasks/ are re-registered against the currently active
# backend (launchd on macOS; systemd --user or cron on Linux).

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

printf 'WARNING: install.sh is deprecated; use `scheduler add` instead.\n' >&2

TASK_NAME="${1:?用法: install.sh <task-name> <time>}"
TIME_EXPR="${2:?用法: install.sh <task-name> \"HH:MM\" [weekdays]}"

HHMM="$(echo "$TIME_EXPR" | awk '{print $1}')"
MODIFIER="$(echo "$TIME_EXPR" | awk '{print $2}')"

case "$MODIFIER" in
    weekdays) SCHEDULE="weekdays $HHMM" ;;
    ""|daily) SCHEDULE="daily $HHMM" ;;
    *)
        echo "install.sh: unsupported modifier '$MODIFIER' — use 'weekdays' or omit." >&2
        exit 2
        ;;
esac

TASK_DIR="$SCRIPT_DIR/tasks/$TASK_NAME"
if [[ ! -d "$TASK_DIR" ]]; then
    echo "install.sh: task directory not found: $TASK_DIR" >&2
    echo "  scaffold it manually or use \`scheduler add\`." >&2
    exit 1
fi

PROMPT_FILE="$TASK_DIR/prompt.md"
if [[ ! -f "$PROMPT_FILE" ]]; then
    echo "install.sh: missing prompt.md in $TASK_DIR" >&2
    exit 1
fi

# Preserve fields from the existing task.yaml so `rm`+`add` doesn't drop them.
# shellcheck source=lib/common.sh
source "$SCRIPT_DIR/lib/common.sh"
YAML="$TASK_DIR/task.yaml"
OLD_OUTPUT_FILE="$(yaml_get output_file "$YAML")"
OLD_OUTPUT_DIR="$(yaml_get output_dir "$YAML")"
OLD_ALLOWED_TOOLS="$(yaml_get allowed_tools "$YAML")"
OLD_ADD_DIRS="$(yaml_get add_dirs "$YAML")"
OLD_SKIP_IF_EXISTS="$(yaml_get skip_if_exists "$YAML")"
OLD_CLAUDE_BIN="$(yaml_get claude_bin "$YAML")"

ARGS=(add "$TASK_NAME" --schedule "$SCHEDULE" --prompt-file "$PROMPT_FILE")
[[ -n "$OLD_OUTPUT_FILE"    ]] && ARGS+=(--output-file    "$OLD_OUTPUT_FILE")
[[ -n "$OLD_OUTPUT_DIR"     ]] && ARGS+=(--output-dir     "$OLD_OUTPUT_DIR")
[[ -n "$OLD_ALLOWED_TOOLS"  ]] && ARGS+=(--allowed-tools  "$OLD_ALLOWED_TOOLS")
[[ -n "$OLD_ADD_DIRS"       ]] && ARGS+=(--add-dirs       "$OLD_ADD_DIRS")
[[ -n "$OLD_SKIP_IF_EXISTS" ]] && ARGS+=(--skip-if-exists "$OLD_SKIP_IF_EXISTS")
[[ -n "$OLD_CLAUDE_BIN"     ]] && ARGS+=(--claude-bin     "$OLD_CLAUDE_BIN")

# Remove-then-re-add so existing tasks get updated schedule + re-registered.
"$SCRIPT_DIR/scheduler" rm "$TASK_NAME" >/dev/null 2>&1 || true
exec "$SCRIPT_DIR/scheduler" "${ARGS[@]}"
