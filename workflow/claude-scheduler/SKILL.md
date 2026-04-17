---
name: claude-scheduler
description: Schedule recurring Claude prompt tasks via the system scheduler (launchd on macOS; systemd --user or crontab on Linux). Invoke when the user asks for a recurring Claude task — triggers include "每天/每周/每小时", "定时", "schedule a claude task", "daily report", "weekly review", "run this prompt every N days", "后台跑 Claude". Claude creates, lists, and removes tasks autonomously through the `scheduler` CLI. Do not use for plain shell cron jobs — route those to cron/at directly.
---

# claude-scheduler

Claude runs this skill by calling the `scheduler` CLI via the Bash tool. You have been pre-authorized: creating a task activates it immediately; removing a task unregisters and deletes it without confirmation.

Locate the CLI relative to this skill file (it lives next to `SKILL.md`). Prefer invoking it by absolute path, e.g. `/path/to/claude-scheduler/scheduler`.

## When to invoke

Invoke this skill when the user asks for something that should happen on a recurring schedule and needs Claude reasoning each time:

- "每天九点写日报"
- "每周五下午 5 点汇总 git 活动"
- "Every weekday morning, check my inbox and summarize"
- "Run this prompt daily at 08:00"

Do NOT invoke for:

- Plain shell commands on a schedule (use `cron`/`at` directly).
- One-off runs (just call `claude -p` inline).
- Windows targets (unsupported).

## CLI cheatsheet

```
scheduler add <name> \
    --schedule "<expr>"       \  # REQUIRED
    --prompt-file <path>      \  # REQUIRED
    [--output-file <path>]       \
    [--output-dir <path>]        \
    [--allowed-tools "<list>"]   \
    [--add-dirs "<comma,list>"]  \
    [--skip-if-exists true|false]

scheduler list [--json]
scheduler rm <name>
scheduler run <name> [YYYY-MM-DD]
scheduler status [<name>]
```

`<expr>` accepts three forms:

- `"daily HH:MM"`          → fires every day at HH:MM
- `"weekdays HH:MM"`       → Monday–Friday at HH:MM
- `"M H * * D"`            → cron form; `D` must be `*` or `1-5`

Output paths support `$DATE`, `$HOME`, and `~`.

## Typical recipes

### 1. Daily report at 09:00, weekdays only

Step 1 — write the prompt to disk (e.g. `~/prompts/daily.md`):

```bash
cat > ~/prompts/daily.md <<'PROMPT'
Read ~/lifelog/$(date +%Y-%m-%d).md and git activity in ~/workspace,
produce a concise daily report in Markdown.
PROMPT
```

Step 2 — register:

```bash
scheduler add daily-report \
    --schedule "weekdays 09:00" \
    --prompt-file ~/prompts/daily.md \
    --output-dir  ~/workspace/daily-reports \
    --allowed-tools "Bash(git:*) Read Glob" \
    --add-dirs "~/workspace,~/lifelog"
```

### 2. Weekly code review every Friday 17:00

```bash
scheduler add weekly-review \
    --schedule "0 17 * * 5" \
    --prompt-file ~/prompts/weekly-review.md \
    --output-file ~/reports/weekly-$DATE.md \
    --allowed-tools "Bash(git:*) Read Glob Grep"
```

### 3. Hourly inbox triage (cron form)

```bash
scheduler add inbox-triage \
    --schedule "0 * * * *" \
    --prompt-file ~/prompts/inbox.md
```

Wait — `*` in the day-of-week slot is supported; `0 * * * *` runs every hour.

### 4. Inspect and remove

```bash
scheduler list --json
scheduler status daily-report
scheduler rm inbox-triage
```

## Contract guarantees (runtime guardrails)

- Stderr from `claude -p` is captured to a per-task log (`~/Library/Logs/claude-scheduler-<name>.log` on macOS, `~/.local/state/claude-scheduler/<name>.log` on Linux).
- Output files are written atomically via `mktemp`+`mv`; a failed run never pollutes the previous output.
- `--skip-if-exists true` (default) lets a task be re-triggered safely without overwriting an already-produced file.

## Authorization model

You may create, modify, and remove tasks without asking. Mention the created task name and schedule in your reply so the user can correct you afterward. If the user asks "what did you schedule?", run `scheduler list` and show the output.

## Backend selection

The CLI probes in order:

1. macOS → `launchd` (writes `~/Library/LaunchAgents/com.claude.scheduler.<name>.plist`)
2. Linux → `systemd --user` if available (writes `~/.config/systemd/user/claude-scheduler-<name>.{service,timer}`)
3. Fallback → `crontab` (adds a marker-commented line: `# claude-scheduler:<name>`)

You do not need to pick the backend explicitly — the CLI handles it.

## Getting help

Every subcommand supports `--help`. Run `scheduler --help` for the top-level menu.
