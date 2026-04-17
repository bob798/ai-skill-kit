#!/usr/bin/env bash
# scheduler.sh — legacy entry point (kept for backward compatibility).
#
# The canonical entry is now the `scheduler` CLI in this directory. This script
# still executes a task directly (same signature as before), but routes through
# `lib/common.sh` so it inherits the fixed YAML parser, stderr-to-log behavior,
# and atomic write semantics.
#
# Usage: scheduler.sh <task-name> [date]

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export SCHEDULER_ROOT="$SCRIPT_DIR"

TASK_NAME="${1:?用法: scheduler.sh <task-name> [date]}"
DATE_VAL="${2:-$(date +%Y-%m-%d)}"

# Delegate to the new unified CLI — the `run` subcommand is the one-to-one
# replacement and already contains the hardship fixes.
exec "$SCRIPT_DIR/scheduler" run "$TASK_NAME" "$DATE_VAL"
