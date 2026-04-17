#!/usr/bin/env bash
# lib/common.sh — shared helpers for claude-scheduler
#
# Exposes:
#   yaml_get <key> <file>                     read a flat YAML scalar
#   atomic_write <dest> <cmd...>              write stdout of cmd atomically into dest
#   log_file_for <task>                       platform-aware log path (creates parent dir)
#   log_info / log_warn / log_error <msg...>  stderr logging
#   detect_platform                           echoes "macos" | "linux" | "other"
#   parse_schedule <expr>                     emits "HH MM DOW" triplet
#                                             DOW = "*" (daily) | "1-5" (weekdays)
#                                             accepts "daily HH:MM", "weekdays HH:MM",
#                                             and cron "M H * * D"
#   claude_bin_path                           resolves claude executable path
#   expand_vars <string> [date]               expands $DATE / $HOME / ~

set -euo pipefail

# ── Platform ────────────────────────────────────────────────────────────────

detect_platform() {
    local uname_s
    uname_s="$(uname -s 2>/dev/null || echo unknown)"
    case "$uname_s" in
        Darwin) echo "macos" ;;
        Linux)  echo "linux" ;;
        *)      echo "other" ;;
    esac
}

# ── YAML parsing ────────────────────────────────────────────────────────────

# Extract a flat "key: value" scalar from a YAML file.
# Uses yq if available, otherwise falls back to awk.
# Handles: inline # comments, double/single-quoted values, blank lines.
yaml_get() {
    local key="$1"
    local file="$2"

    if [[ ! -f "$file" ]]; then
        return 0
    fi

    if command -v yq >/dev/null 2>&1; then
        local result
        result="$(yq -r ".$key // \"\"" "$file" 2>/dev/null || echo "")"
        if [[ "$result" == "null" ]]; then
            echo ""
        else
            echo "$result"
        fi
        return 0
    fi

    awk -v k="$key" '
        BEGIN { found = 0 }
        # Skip blank lines and whole-line comments
        /^[[:space:]]*$/ { next }
        /^[[:space:]]*#/ { next }
        {
            line = $0
            # Strip leading whitespace
            sub(/^[[:space:]]+/, "", line)
            # Match "key: ..." exactly (reject prefixes like "key_extra:")
            if (index(line, k ":") != 1) next
            after = substr(line, length(k) + 1, 1)
            if (after != ":") next
            # Drop "key:" prefix
            val = substr(line, length(k) + 2)
            # Strip leading whitespace after colon
            sub(/^[[:space:]]+/, "", val)
            # Strip inline comment — only when preceded by whitespace and not inside quotes
            # Simplified: drop " #..." at end
            # Handle quoted values first
            if (substr(val, 1, 1) == "\"") {
                # Find matching closing quote
                rest = substr(val, 2)
                end = index(rest, "\"")
                if (end > 0) {
                    val = substr(rest, 1, end - 1)
                } else {
                    val = rest
                }
            } else if (substr(val, 1, 1) == "'"'"'") {
                rest = substr(val, 2)
                end = index(rest, "'"'"'")
                if (end > 0) {
                    val = substr(rest, 1, end - 1)
                } else {
                    val = rest
                }
            } else {
                # Strip trailing comment if preceded by whitespace
                n = length(val)
                for (i = 1; i <= n; i++) {
                    c = substr(val, i, 1)
                    if (c == "#" && i > 1 && substr(val, i-1, 1) ~ /[[:space:]]/) {
                        val = substr(val, 1, i - 2)
                        break
                    }
                }
                # Strip trailing whitespace
                sub(/[[:space:]]+$/, "", val)
            }
            print val
            found = 1
            exit 0
        }
        END { if (!found) print "" }
    ' "$file"
}

# ── Variable expansion ──────────────────────────────────────────────────────

expand_vars() {
    local s="$1"
    local date_val="${2:-$(date +%Y-%m-%d)}"
    # Replace $DATE, $HOME globally; only LEADING ~ (so /foo/~bar stays intact)
    s="${s//\$DATE/$date_val}"
    s="${s//\$HOME/$HOME}"
    if [[ "$s" == "~" ]]; then
        s="$HOME"
    elif [[ "$s" == "~/"* ]]; then
        s="$HOME/${s:2}"
    fi
    echo "$s"
}

# ── Schedule expression ─────────────────────────────────────────────────────

# Translate a schedule expression into a canonical "HH MM DOW" triplet,
# where DOW is "*" (every day) or "1-5" (weekdays). Returns non-zero on invalid.
# Accepted forms:
#   "daily HH:MM"
#   "weekdays HH:MM"
#   cron "M H * * D"      (D is "*" or "1-5")
parse_schedule() {
    local expr="$1"
    expr="${expr# }"
    expr="${expr% }"

    # daily HH:MM
    if [[ "$expr" =~ ^daily[[:space:]]+([0-9]{1,2}):([0-9]{1,2})$ ]]; then
        local h="${BASH_REMATCH[1]}"
        local m="${BASH_REMATCH[2]}"
        printf '%d %d %s\n' "$((10#$h))" "$((10#$m))" '*'
        return 0
    fi

    # weekdays HH:MM
    if [[ "$expr" =~ ^weekdays[[:space:]]+([0-9]{1,2}):([0-9]{1,2})$ ]]; then
        local h="${BASH_REMATCH[1]}"
        local m="${BASH_REMATCH[2]}"
        printf '%d %d %s\n' "$((10#$h))" "$((10#$m))" '1-5'
        return 0
    fi

    # cron "M H * * D" — strict 5-field form
    # Allow both "*" and "1-5" for the DOW field.
    if [[ "$expr" =~ ^([0-9]{1,2})[[:space:]]+([0-9]{1,2})[[:space:]]+\*[[:space:]]+\*[[:space:]]+(\*|1-5)$ ]]; then
        local m="${BASH_REMATCH[1]}"
        local h="${BASH_REMATCH[2]}"
        local d="${BASH_REMATCH[3]}"
        printf '%d %d %s\n' "$((10#$h))" "$((10#$m))" "$d"
        return 0
    fi

    echo "invalid schedule: $expr" >&2
    return 1
}

# ── Logging ─────────────────────────────────────────────────────────────────

log_file_for() {
    local task="$1"
    local platform
    platform="$(detect_platform)"
    local path
    case "$platform" in
        macos)
            path="$HOME/Library/Logs/claude-scheduler-$task.log"
            ;;
        *)
            path="$HOME/.local/state/claude-scheduler/$task.log"
            ;;
    esac
    mkdir -p "$(dirname "$path")"
    # Log files may contain prompt content / claude stderr — keep them user-only.
    if [[ ! -f "$path" ]]; then
        (umask 077 && : > "$path")
    else
        chmod 600 "$path" 2>/dev/null || true
    fi
    echo "$path"
}

# ── Task name validation ────────────────────────────────────────────────────

# Reject names that enable path traversal, shell metacharacters in cron lines,
# XML injection in plist/unit files, or cron marker collision.
validate_task_name() {
    local name="$1"
    if [[ -z "$name" ]]; then
        log_error "task name must not be empty"
        return 2
    fi
    if [[ ! "$name" =~ ^[a-zA-Z0-9][a-zA-Z0-9._-]{0,63}$ ]]; then
        log_error "invalid task name: must be 1-64 chars, start with alnum, contain only [a-zA-Z0-9._-]"
        return 2
    fi
}

# XML-escape a string for safe plist / unit file interpolation.
xml_escape() {
    local s="$1"
    s="${s//&/&amp;}"
    s="${s//</&lt;}"
    s="${s//>/&gt;}"
    s="${s//\"/&quot;}"
    s="${s//\'/&apos;}"
    printf '%s' "$s"
}

log_info()  { printf '[%s][INFO] %s\n'  "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2; }
log_warn()  { printf '[%s][WARN] %s\n'  "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2; }
log_error() { printf '[%s][ERROR] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$*" >&2; }

# ── Atomic write ────────────────────────────────────────────────────────────

# Run a command, capturing stdout to a temp file. On success, mv it to dest.
# On failure, remove the temp file and leave dest untouched.
# Usage: atomic_write <dest> <log_file> <cmd> [args...]
atomic_write() {
    local dest="$1"; shift
    local log_file="$1"; shift
    local tmp
    tmp="$(mktemp "${TMPDIR:-/tmp}/claude-scheduler.XXXXXX")"
    if "$@" > "$tmp" 2>>"$log_file"; then
        mv "$tmp" "$dest"
        return 0
    else
        local rc=$?
        rm -f "$tmp"
        return "$rc"
    fi
}

# ── Claude binary resolution ────────────────────────────────────────────────

claude_bin_path() {
    local override="${1:-}"
    if [[ -n "$override" ]]; then
        echo "$override"
        return 0
    fi
    local p
    p="$(command -v claude 2>/dev/null || true)"
    if [[ -n "$p" ]]; then
        echo "$p"
    else
        echo "/usr/local/bin/claude"
    fi
}

# ── JSON helpers (dependency-free) ──────────────────────────────────────────

# Escape a string for JSON embedding.
json_escape() {
    local s="$1"
    # Order matters: escape backslash first.
    s="${s//\\/\\\\}"
    s="${s//\"/\\\"}"
    s="${s//$'\n'/\\n}"
    s="${s//$'\r'/\\r}"
    s="${s//$'\t'/\\t}"
    printf '"%s"' "$s"
}
