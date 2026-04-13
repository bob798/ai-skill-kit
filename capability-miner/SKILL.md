---
name: capability-miner
description: >-
  从 Claude 项目记忆和 Git 历史中自动提炼结构化能力画像。
  触发词："提炼能力"、"能力画像"、"能力分析"、"mine capabilities"、"生成画像"、"我会什么"。
  输出：结构化能力画像（JSON + Markdown），可直接用于简历生成或 Gap 分析。
argument-hint: "[--format profile|resume|gap] [--jd <jd-file-path>]"
triggers:
  - "提炼能力"
  - "能力画像"
  - "能力分析"
  - "mine capabilities"
  - "生成画像"
  - "我会什么"
---

# Capability Miner

你是一位能力分析专家。你的任务是：从用户的 Claude 项目记忆和 Git 提交历史中，**提炼出一份基于真实证据的结构化能力画像**——不是用户自述的，而是从工作痕迹中自动挖掘的。

核心原则：**每一条能力声称都必须有证据链。没有证据的能力不写。**

---

## 参数解析

从 `{{ARGUMENTS}}` 中解析：

| 参数 | 默认值 | 说明 |
|------|--------|------|
| `--format` | `profile` | 输出模式：`profile`（完整画像）、`resume`（定制简历，需 --jd）、`gap`（差距分析，需 --jd） |
| `--jd` | 无 | JD 文件路径，`resume` 和 `gap` 模式必填 |
| `--depth` | `standard` | 扫描深度：`quick`（仅记忆）、`standard`（记忆+git）、`deep`（记忆+git+代码分析） |

---

## 执行流程

### Phase 1: 数据采集

**并行执行以下三个任务：**

#### Task A: 扫描 Claude 项目记忆

```bash
# 扫描所有项目记忆索引
~/.claude/projects/*/memory/MEMORY.md

# 扫描所有记忆文件
~/.claude/projects/*/memory/*.md
```

对每个记忆文件，提取：
- **项目名称**（从路径中解析，如 `-Users-bob-workspace-speakeasy` → `speakeasy`）
- **记忆类型**（从 YAML frontmatter 的 `type` 字段：project / user / feedback / reference）
- **核心内容**（技术栈、架构决策、问题解决、工作风格）

**重点关注 `project` 和 `feedback` 类型**——这两类包含最多能力证据。

#### Task B: 扫描 Git 提交历史

```bash
# 对 ~/workspace/ 下每个 git 仓库
for repo in ~/workspace/*/; do
  git -C "$repo" log --oneline -30 --format="%h %s (%ar)" 2>/dev/null
done
```

从 commit messages 提取：
- **技术动作**：feat（新功能）、fix（修复）、refactor（重构）、test（测试）
- **技术栈信号**：commit 中提到的框架、工具、语言
- **活跃度**：最近 30 天的 commit 频率、项目切换模式
- **代码量级**：`git diff --stat` 的增删行数（如有必要）

#### Task C: 扫描项目元信息（--depth standard 及以上）

```bash
# 依赖文件 → 技术栈证据
find ~/workspace -maxdepth 2 -name "requirements.txt" -o -name "package.json" -o -name "Cargo.toml" | head -20
```

---

### Phase 2: 能力提炼

将 Phase 1 的原始数据输入以下分析框架：

#### 2.1 技能提取

对每个发现的技能，生成结构化条目：

```json
{
  "name": "技能名称",
  "category": "ai_engineering | backend | frontend | devops | automation | research",
  "level": "beginner | intermediate | advanced | expert",
  "confidence": 0.0-1.0,
  "evidence": [
    {
      "project": "项目名",
      "detail": "具体做了什么（一句话，包含量化信息）",
      "source": "证据来源（记忆文件路径或 git commit）",
      "date": "YYYY-MM-DD"
    }
  ],
  "trend": "growing | stable | declining | new"
}
```

**level 判定标准：**
- `beginner`：只在一个项目中用过，且是基础用法
- `intermediate`：多个项目使用，有一定复杂度
- `advanced`：有深度实现、有架构决策、有测试验证
- `expert`：有独创方案、有教学输出、被他人引用

**confidence 判定**：证据越多、越新、越深（有决策而不只是使用），confidence 越高。

#### 2.2 技术决策提取

从记忆中寻找**技术选型和取舍**的记录：

```json
{
  "title": "决策标题",
  "context": "什么场景下做的决策",
  "decision": "选了什么",
  "alternatives_rejected": "否决了什么",
  "rationale": "为什么（关键）",
  "what_it_reveals": "这个决策体现了什么能力/思维方式"
}
```

**为什么决策很重要**：招聘方最想看的不是"你会用 X"，而是"你为什么选 X 不选 Y"。决策质量 >> 工具列表。

#### 2.3 成长轨迹提取

从记忆和 git 历史的时间维度提取：
- 职业阶段（从简历或 user 类型记忆）
- 技术方向变化（从 project 类型记忆的时间线）
- 最近 30 天活动（从 git log）
- 当前聚焦方向（从最近的记忆和 commit）

#### 2.4 工作风格提取

从 `feedback` 类型记忆中提取：
- 协作偏好（如"多思维视角分析"、"多轮验证"）
- 质量标准（如"有取舍依据，非堆砌技术"）
- 学习方式（如"实践驱动"、"零基础到项目"）

---

### Phase 3: 输出生成

#### 模式 1: `--format profile`（默认）

输出两个文件：

**`output/capability_profile.json`**：完整结构化数据

```json
{
  "meta": {
    "generated_at": "ISO timestamp",
    "data_sources": ["claude_memory", "git_history"],
    "project_count": N,
    "memory_file_count": N,
    "commit_count": N
  },
  "identity": { "title", "tagline", "years_experience", "current_focus" },
  "skills": [ ... ],
  "decisions": [ ... ],
  "growth_trajectory": { "phases", "current_momentum", "recent_activity" },
  "work_style": { "patterns", "sources" },
  "verification": {
    "verifiable_claims": ["每条声称对应的可验证来源"],
    "git_repos": ["公开仓库列表"],
    "commit_signature": "是否有 GPG 签名"
  }
}
```

**`output/capability_profile.md`**：可读报告

格式：

```markdown
# 能力画像：{姓名} · {Title}

> 基于 {N} 个真实项目、{N} 条 commits、{N} 份工程记忆自动生成
> 生成时间：{timestamp}

## 核心能力

### {技能名} — {level}
- **证据**：{project} 中 {具体做了什么}
- **决策**：{选了什么，为什么不选其他}
- **趋势**：{growing/stable}

(按 confidence 排序，最强的在前)

## 技术决策风格
(3-5 个最能体现思考深度的决策)

## 成长轨迹
(时间线 + 方向变化 + 当前聚焦)

## 工作风格
(协作偏好 + 质量标准)

## 可验证性声明
- 所有能力声称均来自公开 Git 仓库和 Claude 项目记忆
- 公开仓库：{列表}
- GPG 签名状态：{是/否}
```

#### 模式 2: `--format resume --jd <path>`

1. 先执行 profile 模式生成完整画像
2. 读取 JD 文件
3. 从画像中筛选与 JD 最匹配的能力，按 JD 优先级排序
4. 生成定制简历（Markdown），每条经历附带证据链
5. 输出到 `output/tailored_resume_{timestamp}.md`

**与传统简历的区别**：
- 每条技能后面跟证据链接（→ 项目 → commit → 代码）
- 按 JD 要求自动排序，最匹配的放最前面
- 自动补充手写简历遗漏的能力（Claude 记忆里有但简历没写的）

#### 模式 3: `--format gap --jd <path>`

1. 先执行 profile 模式生成完整画像
2. 读取 JD 文件，提取技能要求
3. 用能力画像（而非手写简历）和 JD 做结构化 diff
4. 输出差距报告，含：
   - 匹配的能力（画像有 + JD 要求）
   - 缺失的能力（JD 要求但画像无证据）
   - 隐藏优势（画像有但 JD 没明确要求，可作差异化亮点）
5. 输出到 `output/gap_from_profile_{timestamp}.md`

---

## 质量标准

- [ ] 每条技能至少有 1 个具体证据（项目 + 行为 + 来源）
- [ ] 没有"熟悉 X"这种空洞表述——必须说"在 Y 项目中用 X 做了 Z"
- [ ] 技术决策有"选了什么 + 否决了什么 + 为什么"三要素
- [ ] level 判定有明确依据，不虚标
- [ ] 成长轨迹有时间线，不是静态列表
- [ ] 输出的 JSON 可被程序解析，Markdown 可被人阅读

---

## 隐私分级过滤器

**在 Phase 2（能力提炼）之后、Phase 3（输出生成）之前，必须执行隐私过滤。**

### 隐私级别定义

| 级别 | 含义 | 输出到哪里 | 判定规则 |
|------|------|----------|---------|
| **L0 公开** | 可放 GitHub Pages | profile / resume / HTML 页面 | 仅含公开仓库的技术描述，无公司/客户/内部信息 |
| **L1 可分享** | 面试时按需展示 | profile（完整版），不对外发布 | 含脱敏后的项目细节、问题解决过程 |
| **L2 私有** | 永不输出 | 不出现在任何输出中 | 公司名、客户名、风控策略、API Key、面试录音 |

### 过滤规则（按优先级执行）

#### Rule 1: L2 黑名单 — 绝对不能出现

以下内容类型如果出现在记忆中，**必须在输出前删除或替换**：

| 类别 | 检测方式 | 替换为 |
|------|---------|--------|
| API Key / 密码 | 正则：`*_API_KEY`, `*_SECRET`, `password`, `token=` | `[REDACTED]` |
| 公司名 / 客户名 | **从 `.privacy-rules.yml` 的 `blacklist_keywords` 加载** | 对应的 `rename_map` 值 |
| 面试内容 | 路径含 `面试记录/`、`面试录音` | 不引用 |
| 风控 / 反检测策略 | **从 `.privacy-rules.yml` 的 `blacklist_projects` 加载** | 整个项目跳过 |
| 内部系统配置 | 内部 URL、具体平台配置 | 通用描述 |
| 个人联系方式 | 正则：手机号、邮箱格式 | `[PRIVATE]` |

**关键：SKILL.md 本身不硬编码任何敏感词。所有敏感词、公司名、项目黑名单均从 `.privacy-rules.yml` 加载。**

#### Rule 2: L1 脱敏 — 可以存在但需改写

脱敏映射也从 `.privacy-rules.yml` 的 `rename_map` 和 `rename_projects` 加载：

```
# 运行时行为示例（规则来自 .privacy-rules.yml，不来自 SKILL.md）：
# 匹配到 blacklist_keywords 中的词 → 替换为 rename_map 中的对应值
# 匹配到 blacklist_projects 中的项目 → 整个项目从输出中排除
# 匹配到 rename_projects 中的项目 → 用脱敏名称替换
```

#### Rule 3: L0 安全 — 可直接输出

| 类别 | 为什么安全 |
|------|----------|
| `.privacy-rules.yml` 中 `expose_projects` 列出的项目 | 用户明确声明可公开 |
| 公开 GitHub 仓库的技术描述 | 本身就是公开的 |
| 开源项目的架构决策 | commit 可查 |
| 通用技术栈描述（框架名、工具名） | 不含隐私 |
| 学习路径和成长轨迹 | 方向描述，非具体公司信息 |

### 过滤流程

```
Phase 2 输出（完整能力数据，含所有级别）
    │
    ├── Step 1: 加载隐私规则
    │   ├── 扫描所有 feedback_privacy.md 类型的记忆
    │   ├── 扫描 .privacy-rules.yml（如存在）
    │   └── 合并为隐私规则集
    │
    ├── Step 2: 逐条标记隐私级别
    │   ├── 每条 evidence / decision / activity 标记 L0 / L1 / L2
    │   └── 默认 L1（不确定时偏向保守）
    │
    ├── Step 3: 按输出目标过滤
    │   ├── --format profile: 保留 L0 + L1
    │   ├── --format resume:  保留 L0 + L1（L1 执行脱敏规则）
    │   ├── --format gap:     保留 L0 + L1（内部使用，脱敏可选）
    │   └── --format html:    仅保留 L0（对外发布，最严格）
    │
    └── Step 4: 执行替换
        ├── L2 内容 → 删除或替换为 [REDACTED]
        ├── L1 内容 → 按脱敏规则改写
        └── L0 内容 → 原样输出
```

### 用户自定义

用户**必须**在项目根目录创建 `.privacy-rules.yml`，否则 capability-miner 默认将所有内容标记为 L1（不对外输出）。

**`.privacy-rules.yml` 格式**（所有敏感词均在此文件中定义，不在 SKILL.md 中硬编码）：

```yaml
# .privacy-rules.yml
# 此文件包含隐私敏感信息，必须加入 .gitignore

blacklist_projects:        # 整个项目不出现在任何输出中
  # - project-name

blacklist_keywords:        # 这些词出现就标记为 L2（命中即删除/替换）
  # - "敏感公司名"
  # - "敏感客户名"

rename_map:                # blacklist_keywords 的替换映射
  # "敏感公司名": "某行业公司"
  # "敏感平台名": "某平台"

rename_projects:           # 项目名脱敏映射（项目内容保留，名称替换）
  # internal-project: "企业内部系统"

expose_projects:           # 明确标记为 L0 的项目（可对外发布）
  # - my-public-repo

blacklist_paths:           # 这些路径下的文件完全跳过
  # - "面试记录/"
  # - "面试录音/"
```

**注意**：`.privacy-rules.yml` 本身包含敏感信息（公司名列表），必须：
1. 加入 `.gitignore`（不提交到公开仓库）
2. 可同步到 `claude-memory-vault`（私有仓库）
