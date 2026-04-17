# claude-scheduler

Claude-programmable background task runner for recurring Claude prompts.
Cross-platform: launchd on macOS, systemd `--user` or crontab on Linux.
No runtime dependencies beyond bash + the system scheduler.

## The intended usage

Tell Claude:

> "帮我每天 9 点生成一份日报，prompt 放在 `~/prompts/daily.md`。"

or

> "Schedule a weekly code review — every Friday 5 PM, prompt at `~/prompts/review.md`."

Claude will call:

```bash
scheduler add daily-report \
    --schedule "daily 09:00" \
    --prompt-file ~/prompts/daily.md \
    --output-dir  ~/workspace/daily-reports \
    --allowed-tools "Bash(git:*) Read Glob" \
    --add-dirs "~/workspace,~/lifelog"
```

on your behalf. `SKILL.md` in this directory tells Claude Code how to recognise
the trigger and which flags to pass.

## Why this exists

Claude Code's built-in `CronCreate` runs inside the REPL — close the terminal
and the job dies. `claude-scheduler` pushes the scheduling down to the OS:

|                      | `CronCreate` (REPL) | `claude-scheduler` |
| -------------------- | ------------------- | ------------------ |
| Needs REPL open      | yes                 | no                 |
| Survives reboot      | no                  | yes                |
| Max validity         | 7 days              | permanent          |
| Cross-platform       | yes                 | macOS + Linux      |

## Installation

```bash
git clone … ai-skill-kit
cd ai-skill-kit/workflow/claude-scheduler
# Optional: put the CLI on PATH
ln -s "$PWD/scheduler" ~/.local/bin/scheduler
```

No build step. Everything is bash.

Requirements:
- `bash` 4+ (default on Linux; macOS ships 3.2 — install via `brew install bash` if you hit issues, or rely on `/usr/bin/env bash` to pick up a newer one).
- Scheduling backend: launchd (macOS, built-in), or systemd-user, or crontab.
- `claude` CLI on `$PATH` (override per-task with `--claude-bin`).

## Manual usage (for humans)

Most of the time you should let Claude drive. But you can also use the CLI
directly:

```bash
# Register a task
scheduler add daily-report \
    --schedule "weekdays 09:00" \
    --prompt-file ./tasks/daily-report/prompt.md

# List
scheduler list
scheduler list --json

# Status (last-run, next-run, log file)
scheduler status
scheduler status daily-report

# Run now (same entry point the scheduler itself uses)
scheduler run daily-report
scheduler run daily-report 2026-04-15   # override $DATE

# Remove
scheduler rm daily-report
```

Per-subcommand help: `scheduler <sub> --help`.

## Schedule expressions

Three input forms, all equivalent under the hood:

| Form               | Example                 | Meaning                       |
| ------------------ | ----------------------- | ----------------------------- |
| `daily HH:MM`      | `daily 09:00`           | every day at 09:00            |
| `weekdays HH:MM`   | `weekdays 17:30`        | Monday–Friday at 17:30        |
| cron `M H * * D`   | `0 9 * * 1-5`           | strict cron; `D` is `*` / `1-5` |

The CLI rejects anything else with a clear error.

## Task anatomy

Each task lives in `tasks/<name>/` with two files:

```
tasks/<name>/
├── task.yaml      flat key: value config (see below)
└── prompt.md      prompt text fed to `claude -p`
```

`task.yaml` keys (all optional except those marked **required**):

```yaml
schedule: "daily 09:00"         # required; stored for reference
output_dir: ~/workspace/out     # supports $DATE, $HOME, ~
output_file: ~/out/$DATE.md     # if unset, derived from output_dir
allowed_tools: "Read Glob"      # space-separated list for --allowedTools
add_dirs: "~/workspace,~/docs"  # comma-separated for --add-dir
skip_if_exists: true            # skip if output_file already exists
claude_bin: /usr/local/bin/claude
```

Hand-editing a `task.yaml` is supported. Re-register afterwards so the backend
reflects the change:

```bash
scheduler rm <name>
scheduler add <name> --schedule "…" --prompt-file tasks/<name>/prompt.md
```

## What happens on each trigger

The system scheduler (launchd / systemd / cron) executes:

```bash
scheduler run <name>
```

which:

1. Loads `tasks/<name>/task.yaml` via a resilient YAML reader (`yq` if present; awk fallback that handles inline `#` comments, quotes, blanks).
2. Writes stderr from `claude -p` to the per-task log:
   - macOS: `~/Library/Logs/claude-scheduler-<name>.log`
   - Linux: `~/.local/state/claude-scheduler/<name>.log`
3. Writes stdout to a temp file, then `mv`s it into place — a failed run never pollutes the previous output.
4. If `skip_if_exists: true` and the output already exists, exits 0 without calling `claude`.

## Backends

| Platform | Backend            | Artifacts                                                              |
| -------- | ------------------ | ---------------------------------------------------------------------- |
| macOS    | launchd            | `~/Library/LaunchAgents/com.claude.scheduler.<name>.plist`             |
| Linux    | systemd --user     | `~/.config/systemd/user/claude-scheduler-<name>.{service,timer}`       |
| Linux    | crontab (fallback) | `crontab` line tagged with `# claude-scheduler:<name>`                 |

Selection order: launchd → systemd --user → crontab. The first one whose
`backend_available` probe succeeds is used.

## Limits

- The machine must be awake at the scheduled time (launchd + systemd-user with
  `Persistent=true` will catch up after sleep; cron will not).
- Every trigger spends Claude API tokens.
- No network callback / webhook.
- Claude-prompt tasks only. Plain shell cron jobs belong in `cron`/`at`.
- Windows is not supported.

## Files

```
claude-scheduler/
├── SKILL.md             discovery entry for Claude Code
├── scheduler            main CLI (this is what you and Claude call)
├── scheduler.sh         legacy shim; now forwards to `scheduler run`
├── install.sh           legacy shim; forwards to `scheduler add`
├── uninstall.sh         legacy shim; forwards to `scheduler rm`
├── status.sh            legacy shim; forwards to `scheduler status`
├── lib/
│   ├── common.sh        shared helpers (yaml_get, atomic_write, logging)
│   ├── task.sh          task directory CRUD
│   └── backends/
│       ├── launchd.sh
│       ├── systemd.sh
│       └── cron.sh
└── tasks/
    └── daily-report/    bundled example; still works out of the box
```

## Migration from the old install.sh

```bash
# Old (still works, but prints a deprecation warning)
./install.sh daily-report "09:03 weekdays"

# New
./scheduler add daily-report \
    --schedule "weekdays 09:03" \
    --prompt-file tasks/daily-report/prompt.md
```

Task directories created under the old layout are forward-compatible — the new
CLI reads the same `task.yaml` + `prompt.md` shape.
