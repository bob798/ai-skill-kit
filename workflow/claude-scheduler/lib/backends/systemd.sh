#!/usr/bin/env bash
# lib/backends/systemd.sh — Linux systemd --user backend
#
# Required exports:
#   backend_available
#   backend_register / backend_unregister / backend_is_registered
#   backend_last_run / backend_next_run

set -euo pipefail

: "${SCHEDULER_ROOT:?SCHEDULER_ROOT must be set}"
# shellcheck source=../common.sh
source "$SCHEDULER_ROOT/lib/common.sh"

BACKEND_KIND="systemd"

_systemd_unit_dir() { echo "$HOME/.config/systemd/user"; }
_systemd_unit_name() { echo "claude-scheduler-$1"; }
_systemd_service_path() { echo "$(_systemd_unit_dir)/$(_systemd_unit_name "$1").service"; }
_systemd_timer_path()   { echo "$(_systemd_unit_dir)/$(_systemd_unit_name "$1").timer"; }

backend_available() {
    [[ "$(detect_platform)" == "linux" ]] || return 1
    command -v systemctl >/dev/null 2>&1 || return 1
    # systemd --user must be reachable. Two probes: user bus env + dir writability.
    if systemctl --user is-enabled default.target >/dev/null 2>&1; then
        mkdir -p "$(_systemd_unit_dir)"
        return 0
    fi
    # Fallback probe: unit dir is writable. Avoids hard failure when is-enabled is
    # noisy but the user bus works enough to reload.
    if mkdir -p "$(_systemd_unit_dir)" 2>/dev/null && [[ -w "$(_systemd_unit_dir)" ]]; then
        return 0
    fi
    return 1
}

backend_is_registered() {
    [[ -f "$(_systemd_timer_path "$1")" ]]
}

# Map our canonical triplet to systemd OnCalendar syntax.
_systemd_on_calendar() {
    local hour="$1"
    local minute="$2"
    local dow="$3"
    if [[ "$dow" == "1-5" ]]; then
        printf 'Mon..Fri *-*-* %02d:%02d:00\n' "$hour" "$minute"
    else
        printf '*-*-* %02d:%02d:00\n' "$hour" "$minute"
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

    local unit service_path timer_path on_cal log
    unit="$(_systemd_unit_name "$name")"
    service_path="$(_systemd_service_path "$name")"
    timer_path="$(_systemd_timer_path "$name")"
    on_cal="$(_systemd_on_calendar "$hour" "$minute" "$dow")"
    log="$(log_file_for "$name")"

    mkdir -p "$(_systemd_unit_dir)"

    # Name is regex-validated upstream (no newlines / brackets); quote paths
    # in ExecStart as defense-in-depth so a spaceful $SCHEDULER_ROOT works.
    cat > "$service_path" <<EOF
[Unit]
Description=claude-scheduler task: $name
After=default.target

[Service]
Type=oneshot
ExecStart=/usr/bin/env bash "$SCHEDULER_ROOT/scheduler" run "$name"
StandardOutput=append:$log
StandardError=append:$log
Environment=HOME=$HOME
EOF

    cat > "$timer_path" <<EOF
[Unit]
Description=Timer for claude-scheduler task: $name

[Timer]
OnCalendar=$on_cal
Persistent=true
Unit=$unit.service

[Install]
WantedBy=timers.target
EOF

    systemctl --user daemon-reload 2>>"$log" || true
    systemctl --user enable --now "$unit.timer" 2>>"$log"
}

backend_unregister() {
    local name="$1"
    local unit service_path timer_path
    unit="$(_systemd_unit_name "$name")"
    service_path="$(_systemd_service_path "$name")"
    timer_path="$(_systemd_timer_path "$name")"
    if [[ -f "$timer_path" ]]; then
        systemctl --user disable --now "$unit.timer" 2>/dev/null || true
    fi
    rm -f "$timer_path" "$service_path"
    systemctl --user daemon-reload 2>/dev/null || true
    return 0
}

backend_last_run() {
    local name="$1"
    local unit
    unit="$(_systemd_unit_name "$name")"
    if ! backend_is_registered "$name"; then
        echo "never"
        return 0
    fi
    local val
    val="$(systemctl --user show "$unit.timer" -p LastTriggerUSec --value 2>/dev/null || echo "")"
    if [[ -z "$val" || "$val" == "n/a" || "$val" == "0" ]]; then
        echo "never"
    else
        # systemd shows "Tue 2026-04-16 09:00:00 UTC" etc.; keep as-is for readability.
        echo "$val"
    fi
}

backend_next_run() {
    local name="$1"
    local unit
    unit="$(_systemd_unit_name "$name")"
    if ! backend_is_registered "$name"; then
        echo "unknown"
        return 0
    fi
    local val
    val="$(systemctl --user show "$unit.timer" -p NextElapseUSecRealtime --value 2>/dev/null || echo "")"
    if [[ -z "$val" || "$val" == "n/a" || "$val" == "0" ]]; then
        echo "unknown"
    else
        echo "$val"
    fi
}
