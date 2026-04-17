#!/usr/bin/env bash
# uninstall.sh — DEPRECATED shim.
# Use `scheduler rm <name>` instead.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

printf 'WARNING: uninstall.sh is deprecated; use `scheduler rm` instead.\n' >&2

TASK_NAME="${1:?用法: uninstall.sh <task-name>}"
exec "$SCRIPT_DIR/scheduler" rm "$TASK_NAME"
