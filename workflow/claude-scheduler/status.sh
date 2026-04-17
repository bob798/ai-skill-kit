#!/usr/bin/env bash
# status.sh — DEPRECATED shim.
# Use `scheduler status` instead.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

printf 'WARNING: status.sh is deprecated; use `scheduler status` instead.\n' >&2

exec "$SCRIPT_DIR/scheduler" status "$@"
