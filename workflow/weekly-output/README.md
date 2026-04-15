# weekly-output

A Claude Code skill for deep weekly retrospectives. Transforms fragmented daily notes into structured insights using four proven methodologies: **BASB**, **Zettelkasten**, **T-shaped growth**, and **GTD**.

## What it does

1. Reads all daily note files for the specified week
2. Organizes content into three tracks: **Research → Practice → Output**
3. Links new conclusions to previous weeks (Zettelkasten)
4. Runs vertical (depth) + horizontal (breadth) analysis on each key topic
5. Forces a GTD inbox clear — items pending 2+ weeks must be decided
6. Produces an **Express checklist**: what can be published *today*
7. Saves a structured retro doc + todo file

## Why four methodologies

| Method | What it solves |
|---|---|
| BASB (CODE) | Most people stop at Distill and never Express (publish) |
| Zettelkasten | New insights feel new every week — linking prevents repeated discovery |
| T-shaped growth | Horizontal breadth tells you where to go deeper |
| GTD Weekly Review | Saved links accumulate and drain attention without forcing a decision |

## Usage

```
/weekly-output 2026-04-01 2026-04-04
```

Or just the start date (defaults to a 7-day window):

```
/weekly-output 2026-04-01
```

You can also paste your own reflection notes after the dates — the skill will merge them into the analysis.

## Output files

Each week gets its own subdirectory:

```
[retro-dir]/
├── t-map.md              # T-shaped growth map — cumulative, updated every week
├── 2026-W14/
│   ├── retro.md          # Full retro: TL;DR, conclusions, T-map delta, GTD, Express checklist
│   └── todo.md           # P0/P1/P2 todos + Express tracking + 4 weekly review questions
├── 2026-W15/
│   ├── retro.md
│   └── todo.md
└── ...
```

`t-map.md` is **shared across all weeks** — it accumulates your T-shaped growth history and is only appended to, never rebuilt.

Zettelkasten links use Obsidian wiki-link format for native graph navigation:
```markdown
← [[2026-W13/retro#Conclusion Title]]
```

## Setup

**1. Configure paths** — edit the two lines at the top of `SKILL.md`:

```yaml
# DAILY_DIR: ~/Documents/notes/daily          # daily YYYY-MM-DD*.md files
# RETRO_DIR: ~/Documents/notes/weekly-retro   # weekly retro output directory
```

Uncomment and set both lines to match your actual directory structure.

**2. Ensure directories exist:**

```bash
mkdir -p ~/Documents/notes/daily ~/Documents/notes/weekly-retro
```

> The skill will create weekly subdirectories automatically.

## Skill structure

```
weekly-output/
├── SKILL.md      # skill definition (Claude reads this)
└── README.md     # this file
```

## Step-by-step flow

```
Step 1  BASB Capture      Read all daily notes for the week
Step 2  BASB Organize     Classify into Research / Practice / Output
Step 3  Zettelkasten      Link new conclusions to previous week's retro
Step 4  BASB Distill      Vertical depth + horizontal breadth analysis
        T-shaped map      Update current T-shape, identify gaps
Step 5  GTD Inbox clear   Force A/B/C/D decision on every pending item
Step 6  BASB Express      Build publish-ready checklist
Step 7  Write retro doc   Save YYYY-WNN.md
Step 8  Write todo file   Save YYYY-WNN-todo.md
```

## The Express checklist (Step 6)

The most commonly skipped step. Every retro ends with:

| Content | What's missing before publish | Est. time |
|---|---|---|
| Publish-ready | Nothing | Now |
| Needs intro/outro | Write intro + conclusion | 1h |
| Needs experiment | Run minimum viable test | 2–4h |
| Blocked by fundamentals | Learn ___ first | N weeks |

## The 4 weekly review questions

Generated in every todo file:

1. Which concept moved from "understood" to "muscle memory"? *(BASB Distill check)*
2. Which note can be published today? *(Express check)*
3. Any items pending 2+ weeks? *(GTD check)*
4. Which new conclusion links to a previous one? *(Zettelkasten check)*

## Voice note support

Daily notes recorded via voice-to-text often contain transcription errors. The skill automatically attempts to restore original intent before analysis (e.g. "three cities" → "three dimensions").

## Requirements

- [Claude Code](https://claude.ai/code)
- Daily notes in Markdown format, named `YYYY-MM-DD*.md`
- Retro directory must exist before first run

## License

MIT
