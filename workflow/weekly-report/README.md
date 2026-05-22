# weekly-report

A weekly status reporting skill for project leads. Produces a single-page PNG (for stakeholder slides / email) and an embedded Markdown copy block (for IM / issue comments) — both rendered from the same HTML source.

## What it does

1. Asks for this week's progress data (completed work, next week's plan, risks)
2. Computes three progress metrics: monthly task %, monthly time %, total goal %
3. Picks a rhythm verdict (on-track / yellow / red) by comparing task vs time
4. Fills a 4-section card template (Goal / Month / Next Week / Risks)
5. Renders to PNG via headless Chrome (880×820, 2× retina)
6. Provides a Markdown text version + one-click copy button for posting

## Why dual progress bars

Single "progress 50%" is ambiguous — 50% of what? Task or time?

Dual bars show both at once:

| Task vs Time | Verdict | Visual narrative |
|---|---|---|
| Task ≥ Time | 🟢 on-track or ahead | "节奏对齐" |
| Time − Task ≤ 10% | 🟢 small gap, normal | "节奏对齐" |
| Time − Task 11–25% | 🟡 catch up this week | "时间走在前面 X%，本周需追赶" |
| Time − Task > 25% | 🔴 red flag | "进度落后 X%，需扩资源或砍范围" |

## Usage

```
/weekly-report
```

Then provide:

- This week's completed work (1–3 items)
- Next week's one-line objective
- Next week's actions (3–5 items, with dates)
- Risks (1–2 items, with mitigations)
- Optional: project name, total goal, ticket system

## Output files

Each week gets its own subdirectory under the project root:

```
reports/
├── 2026-05-22/
│   ├── weekly-report.html   # Source: SVG card + Markdown block
│   └── weekly-report.png    # Rendered card (1760×1640 at 2×)
├── 2026-05-29/
│   └── ...
```

## Design principles

- **Leader-facing**: 5-second scan, 30-second read
- **No AI jargon**: avoid "leverage / empower / synergy / 落地 / 赋能 / 闭环" filler
- **Numbers with denominators**: `~50% (10.8 of 22 SP)`, not bare `50%`
- **Risks include mitigations**, not just complaints
- **If-then sentences** over vague commitments

## Cloning to a project-specific version

For projects with stable module lists and recurring metrics, clone this skill and bake in the project context:

```bash
cp -r workflow/weekly-report ~/.claude/skills/myproject-weekly-report
# Edit SKILL.md frontmatter `name` field
# Bake project-specific data sources, story point estimates, and milestone dates
```

## Rendering command

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-sandbox \
  --force-device-scale-factor=2 \
  --window-size=880,820 \
  --hide-scrollbars \
  --screenshot=weekly-report.png \
  --default-background-color=00ffffff \
  "file:///$(pwd)/weekly-report.html"
```

For Linux / Windows, replace the Chrome path. The Markdown copy block lives below the SVG (`y > 820`) and is not captured by the screenshot.
