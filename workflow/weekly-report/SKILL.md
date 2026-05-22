---
name: weekly-report
description: >
  通用周报生成 Skill。4 段结构（总目标 / 本月 / 下周 / 风险）+ 双进度条对比（任务 vs 时间）+ 总目标进度条 + Markdown 文字版（一键复制）。输出单页 PNG（领导面向汇报）。当用户说"做周报"、"出周报"、"本周汇报"、"周五汇报"、"生成周报"、"周会用图"时触发。适用于任意项目的周期性进度汇报。
---

# Weekly Report Skill

为任意项目生成单页周报，输出两个产物：

1. **PNG**：领导面向的可视化（双进度条 + 4 段结构）
2. **Markdown 文字版**：嵌在 HTML 里，一键复制，发 IM / 邮件 / 评论

## 设计理念

- **领导面向**：5 秒看懂状态，30 秒读完全文
- **双进度条**：用"任务完成 vs 时间已用"对比，避免单一百分比的歧义
- **去 AI 黑话**：用"搞定 / 凑不齐 / 负担减轻"，不用"赋能 / 落地 / 闭环"
- **双产物对齐**：同一份 HTML 渲出 PNG（视觉版）+ 一键复制 Markdown（文字版）

## 何时用

- 用户主动说 "做周报"、"出周报"、"本周汇报"、"周五汇报"
- 项目周期性汇报需求（周报 / 月报 / 阶段报告）

## 何时另起专用版

如果项目有以下特征，建议克隆出项目专用 skill：

- 固定的工单系统（Jira / GitLab Issues / Linear）+ 主 issue key
- 稳定的模块列表 + 工作量估算
- 重复出现的进度口径与术语

克隆步骤：

```bash
cp -r ~/.claude/skills/weekly-report ~/.claude/skills/<project>-weekly-report
# 改 SKILL.md 里的 name、description、加入项目专有信息
# 改 weekly-report-template.html 的固定字段
```

## 输入清单

**首次或换项目时问一次（项目级）**：

- 项目名 + 总目标（一句话，如 "X 月 X 日完成 X 系统"）
- 总目标进度 %（带分母说明）
- 工单系统 + 主 issue key（可选，用于挂附件）

**每周必问（本周级）**：

| 项 | 例 |
|---|---|
| 本月任务进度 % | "本月计划 50 SP 完成 36 SP ≈ 72%" |
| 本月时间进度 % | "本月 18 工作日用了 13 个 ≈ 72%" |
| 本月主题（1 句） | "本月重点是后端基础" |
| 本周完成（1-3 条） | "X 模块设计 / 开发 / 测试" |
| 下周一句话目标 | "敲定 Y 方案并做完，周五跑通端到端" |
| 下周动作（3-5 条，带日期） | "周一前定下 Y 方案" |
| 风险（1-2 条，带应对） | "下周节奏紧，周四晚先同步阶段进度" |

## 进度口径（必须做的事）

**每个百分比必须带分母**：

- ❌ "进度 50%"（歧义：50% of 什么？）
- ✅ "本月任务 ~50%（已完成 SP / 本月计划 SP）"

**节奏判断**（任务 vs 时间）：

| 任务 vs 时间 | 含义 | 视觉文案 |
|---|---|---|
| 任务 ≥ 时间 | 🟢 在轨或超前 | "节奏对齐" / "提前" |
| 时间 − 任务 ≤ 10% | 🟢 小差距，正常 | "节奏对齐" |
| 时间 − 任务 11-25% | 🟡 警告，本周追 | "时间走在前面 X%，本周需追赶" |
| 时间 − 任务 > 25% | 🔴 重点关注 | "进度落后 X%，需扩资源或砍范围" |

## 文案风格（人话，无 AI 感）

**用**：搞定、做完、跑通、接通、收尾、敲定、负担减轻、节奏紧凑、凑不齐、串通

**不用**：落地、赋能、打通、闭环、抓手、对齐目标、推进、复盘、加持、提质增效、深度

**句式**：

- ✅ "X 模块本周搞定，月底联调就完整；搞不定就缺一块"
- ❌ "X 模块是本月关键路径项，需要重点关注以确保联调顺利交付"

**领导面向**：

- 一句话总结 > 长段落
- 数字带分母 > 单数百分比
- 风险带应对 > 单纯列风险
- if-then 句式（"如果 X，就 Y；不行就 Z"）> 模糊承诺

## 流程

```
1. 收集输入   →  ask 用户填上面的输入清单
2. 算口径     →  本月任务 / 本月时间 / 总目标 三个数字
3. 判节奏     →  绿 / 黄 / 红
4. 复制模板   →  reports/YYYY-MM-DD/（或项目指定目录）
5. 填 HTML    →  Edit 工具填字段，注意 SVG 和 MD 块同步双写
6. 渲 PNG     →  Chrome headless
7. 校对       →  Read PNG 看视觉，浏览器打开 HTML 看 MD 块
8. 上传       →  挂工单附件 + 加评论（如有）
```

## 模板位置

`~/.claude/skills/weekly-report/weekly-report-template.html`

模板含：

- SVG 卡片（880 × 820，4 段结构）
- 下方 Markdown 复制块（不进入 PNG 截图区域）
- 一键复制按钮（execCommand + Clipboard API 双兜底）

## 渲染命令

```bash
"/Applications/Google Chrome.app/Contents/MacOS/Google Chrome" \
  --headless=new --disable-gpu --no-sandbox \
  --force-device-scale-factor=2 \
  --window-size=880,820 \
  --hide-scrollbars \
  --screenshot=weekly-report.png \
  --default-background-color=00ffffff \
  "file:///<absolute path>/weekly-report.html"
```

要点：

- `--force-device-scale-factor=2` 出 2× 高清图
- `--window-size` 必须 = SVG 宽高（880×820），否则截图会截断或留白
- `file:///` 必须绝对路径
- 截图只捕获 viewport（window-size），SVG 之下的 MD 块不会进 PNG

**Linux / Windows**：把可执行路径换成对应平台的 Chrome / Chromium / Edge 路径，其他参数不变。

## 文件位置约定

```
reports/                     # 在项目根目录
├── 2026-05-22/              # 每周一个文件夹（日期 = 截止日，通常周五）
│   ├── weekly-report.html   # 源（含 SVG + MD 块）
│   └── weekly-report.png    # 渲染产物
├── 2026-05-29/
│   └── ...
```

## 颜色（设计语言）

| 用途 | 颜色 | hex |
|---|---|---|
| 在轨 / 健康 / 总目标 | 绿色 | `#10b981` / 深绿文字 `#047857` |
| 本月任务 / 黄灯 | 琥珀 | `#f59e0b` / 棕色文字 `#92400e` |
| 本月时间 / 信息 | 蓝色 | `#3b82f6` / 深蓝文字 `#1d4ed8` |
| 红灯 / 阻塞 | 红色 | `#ef4444` / 深红文字 `#b91c1c` |
| 头部条 | 深蓝 | `#1e3a8a` |
| 文字主色 | 灰深 | `#111827` |
| 文字次色 | 灰中 | `#374151` / `#6b7280` |
| 分割线 | 灰浅 | `#e5e7eb` |

## SVG 关键坐标（用于改进度条宽度）

```
SVG 宽 880 × 高 820

Section 1 (y=110)：总目标
  - 总目标进度条：320 宽，fill_width = 320 × percent
Section 2 (y=230)：本月
  - 本月任务条：320 宽
  - 本月时间条：320 宽
Section 3 (y=430)：下周
Section 4 (y=640)：风险
```

进度条 fill 计算：

- 30% → `width="96"`
- 49% → `width="157"`
- 50% → `width="160"`
- 72% → `width="230"`
- 100% → `width="320"`

## Markdown 复制块（HTML 内置）

`</svg>` 之后是 MD 复制块：

- `<pre id="md-content">` 含完整 MD 文字
- 「复制 Markdown」按钮：`execCommand('copy')` + `navigator.clipboard` 双兜底
- 位于 y > 820 区域，Chrome headless 截图不会捕获

**每周更新要点**：

- 改 SVG 数字时，**必须同步改 `<pre>` 里的对应文字**（SVG 和 MD 是双写关系）
- 浏览器打开 HTML 校对 MD，测试按钮

## 工单系统上传（可选）

如有 Jira / GitLab / Linear 等工单系统 + 主 issue：

```text
# 评论格式（纯文本，避免 Markdown 转换吞符号）

YYYY-MM-DD 周报已挂附件区

  · 本月任务 ~X% / 本月时间 ~Y%（节奏判断）
  · 下周一句话：...
  · 源文件：reports/YYYY-MM-DD/weekly-report.html
```

## 检查清单（生成前过一遍）

- [ ] 每个百分比都有 label 标明范围
- [ ] 4 段结构齐全（总目标 / 本月 / 下周 / 风险）
- [ ] 文案无 AI 黑话
- [ ] 下周动作有具体日期 / 验收点
- [ ] 风险包含动作或缓解
- [ ] SVG 与 MD 块内容一致
- [ ] PNG 已渲染且视觉无误
- [ ] 工单系统已挂附件 + 评论（如适用）

## 不要做的事

- ❌ 不要写"裸"百分比（必须带分母 label）
- ❌ 不要做甘特、燃尽等工程详图（领导汇报用单页卡片）
- ❌ 不要 SVG 内放 emoji（PNG 渲染可能丢字符）
- ❌ 不要假装数据（数字以用户提供为准，AI 不主动调高）
- ❌ 不要写 AI 黑话（落地 / 赋能 / 打通 / 闭环 / 抓手 等）
- ❌ 不要在 PNG 里嵌 MD 块（要分离）
- ❌ 不要忘了同步双写 SVG 与 MD 文本

## 与其他相关 skill 的关系

| Skill | 用途 |
|---|---|
| **weekly-report**（本 skill） | 项目周期性汇报，输出领导面向单页 PNG + MD |
| **ai-skills:weekly-output** | 个人复盘（碎片化 daily notes → 周复盘文档），非项目汇报 |
| **ai-skills:article-illustrator** | 文章配图、知识卡片等长内容 SVG，非数据可视化 |

新项目从本 skill 起步，跑几周后稳定再 clone 出项目专用版。
