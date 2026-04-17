#!/usr/bin/env bash
# lib/backends/cron.sh — crontab fallback backend
#
# Uses a marker comment on each managed line so we can safely insert/remove
# without touching unrelated user cron entries.
#
#   # claude-scheduler:<task-name>
#   M H * * D /bin/bash /path/to/scheduler run <task-name> >>LOG 2>&1

set -euo pipefail

: "${SCHEDULER_ROOT:?SCHEDULER_ROOT must be set}"
# shellcheck source=../common.sh
source "$SCHEDULER_ROOT/lib/common.sh"

BACKEND_KIND="cron"

_cron_marker() { echo "# claude-scheduler:$1"; }

backend_available() {
    command -v crontab >/dev/null 2>&1 || return 1
    return 0
}

_cron_current() {
    # Echo the current user crontab; empty if none.
    crontab -l 2>/dev/null || true
}

# Return managed block for <name>: marker line + following command line.
# Emits lines; caller handles presence test.
_cron_extract_block() {
    local name="$1"
    local marker
    marker="$(_cron_marker "$name")"
    _cron_current | awk -v m="$marker" '
        $0 == m { found = 1; print; next }
        found   { print; found = 0; next }
    '
}

# Remove the marker + one following line from the crontab buffer on stdin.
_cron_strip_block() {
    local name="$1"
    local marker
    marker="$(_cron_marker "$name")"
    awk -v m="$marker" '
        { lines[NR] = $0 }
        END {
            skip = 0
            for (i = 1; i <= NR; i++) {
                # Marker line: skip it + the single command line that follows.
                if (lines[i] == m) { skip = 1; continue }
                if (skip > 0)      { skip--;  continue }
                print lines[i]
            }
        }
    '
}

backend_is_registered() {
    local name="$1"
    local block
    block="$(_cron_extract_block "$name")"
    [[ -n "$block" ]]
}

backend_register() {
    local name="$1"
    local expr="$2"

    local triplet
    if ! triplet="$(parse_schedule "$expr")"; then
        return 1
    fi
    local hour minute dow
    read -r hour minute dow <<< "$triplet"

    local log
    log="$(log_file_for "$name")"

    local marker cmd_line
    marker="$(_cron_marker "$name")"
    # Cron format: "M H * * D". Quote all paths/names for shell safety.
    # (name is also regex-validated upstream; this is defense-in-depth.)
    cmd_line=$(printf "%d %d * * %s /usr/bin/env bash '%s/scheduler' run '%s' >> '%s' 2>&1" \
        "$minute" "$hour" "$dow" "$SCHEDULER_ROOT" "$name" "$log")

    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/claude-scheduler-cron.XXXXXX")"
    # Start from current crontab minus any existing block for this task
    _cron_current | _cron_strip_block "$name" > "$tmp"
    # Append new block
    printf '%s\n%s\n' "$marker" "$cmd_line" >> "$tmp"
    crontab "$tmp"
    rm -f "$tmp"
}

backend_unregister() {
    local name="$1"
    if ! backend_is_registered "$name"; then
        return 0
    fi
    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/claude-scheduler-cron.XXXXXX")"
    _cron_current | _cron_strip_block "$name" > "$tmp"
    crontab "$tmp"
    rm -f "$tmp"
    return 0
}

backend_last_run() {
    local name="$1"
    local log
    log="$(log_file_for "$name")"
    if [[ ! -f "$log" ]]; then
        echo "never"
        return 0
    fi
    local ts
    if [[ "$(detect_platform)" == "macos" ]]; then
        ts="$(stat -f '%Sm' -t '%Y-%m-%dT%H:%M:%S' "$log" 2>/dev/null || echo "")"
    else
        ts="$(stat -c '%y' "$log" 2>/dev/null | cut -d'.' -f1 | tr ' ' 'T' || echo "")"
    fi
    if [[ -z "$ts" ]]; then
        echo "never"
    else
        echo "$ts"
    fi
}

backend_next_run() {
    # cron does not expose next-fire; surface the stored expr instead of computing it.
    echo "unknown"
}
