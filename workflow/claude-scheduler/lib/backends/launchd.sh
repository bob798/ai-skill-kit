#!/usr/bin/env bash
# lib/backends/launchd.sh — macOS launchd backend
#
# Required exports:
#   backend_available
#   backend_register   <name> <schedule-expr>
#   backend_unregister <name>
#   backend_is_registered <name>
#   backend_last_run   <name>
#   backend_next_run   <name>

set -euo pipefail

: "${SCHEDULER_ROOT:?SCHEDULER_ROOT must be set}"
# shellcheck source=../common.sh
source "$SCHEDULER_ROOT/lib/common.sh"

BACKEND_KIND="launchd"

_launchd_label() { echo "com.claude.scheduler.$1"; }
_launchd_plist() { echo "$HOME/Library/LaunchAgents/$(_launchd_label "$1").plist"; }

backend_available() {
    [[ "$(detect_platform)" == "macos" ]] || return 1
    command -v launchctl >/dev/null 2>&1 || return 1
    [[ -d "$HOME/Library/LaunchAgents" ]] || mkdir -p "$HOME/Library/LaunchAgents"
    return 0
}

backend_is_registered() {
    [[ -f "$(_launchd_plist "$1")" ]]
}

_launchd_build_calendar() {
    local hour="$1"
    local minute="$2"
    local dow="$3"   # "*" or "1-5"

    if [[ "$dow" == "1-5" ]]; then
        printf '    <key>StartCalendarInterval</key>\n    <array>\n'
        for d in 1 2 3 4 5; do
            printf '        <dict>\n            <key>Weekday</key><integer>%d</integer>\n            <key>Hour</key><integer>%d</integer>\n            <key>Minute</key><integer>%d</integer>\n        </dict>\n' "$d" "$hour" "$minute"
        done
        printf '    </array>\n'
    else
        printf '    <key>StartCalendarInterval</key>\n    <dict>\n        <key>Hour</key><integer>%d</integer>\n        <key>Minute</key><integer>%d</integer>\n    </dict>\n' "$hour" "$minute"
    fi
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

    local label plist log
    label="$(_launchd_label "$name")"
    plist="$(_launchd_plist "$name")"
    log="$(log_file_for "$name")"

    local claude_bin path_dir
    claude_bin="$(claude_bin_path "$(yaml_get "claude_bin" "$SCHEDULER_ROOT/tasks/$name/task.yaml")")"
    path_dir="$(dirname "$claude_bin")"

    # Unload existing first (idempotent re-register)
    if [[ -f "$plist" ]]; then
        launchctl unload "$plist" 2>>"$log" || true
    fi

    local calendar
    calendar="$(_launchd_build_calendar "$hour" "$minute" "$dow")"

    # XML-escape every interpolated value (defense-in-depth; name is also
    # alnum/._- restricted by validate_task_name upstream).
    local label_x name_x script_x log_x path_dir_x home_x
    label_x="$(xml_escape "$label")"
    name_x="$(xml_escape "$name")"
    script_x="$(xml_escape "$SCHEDULER_ROOT/scheduler")"
    log_x="$(xml_escape "$log")"
    path_dir_x="$(xml_escape "$path_dir")"
    home_x="$(xml_escape "$HOME")"

    cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label_x</string>
    <key>ProgramArguments</key>
    <array>
        <string>/bin/bash</string>
        <string>$script_x</string>
        <string>run</string>
        <string>$name_x</string>
    </array>
$calendar    <key>StandardOutPath</key>
    <string>$log_x</string>
    <key>StandardErrorPath</key>
    <string>$log_x</string>
    <key>EnvironmentVariables</key>
    <dict>
        <key>PATH</key>
        <string>$path_dir_x:/usr/local/bin:/usr/bin:/bin</string>
        <key>HOME</key>
        <string>$home_x</string>
    </dict>
</dict>
</plist>
EOF

    launchctl load "$plist" 2>>"$log"
}

backend_unregister() {
    local name="$1"
    local plist
    plist="$(_launchd_plist "$name")"
    if [[ -f "$plist" ]]; then
        launchctl unload "$plist" 2>/dev/null || true
        rm -f "$plist"
    fi
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
    # Use file mtime as a conservative "last activity" signal.
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
    # launchctl does not expose next-fire-time portably; return unknown.
    # (launchctl print on modern macOS shows it, but format is unstable.)
    echo "unknown"
}
