# AI Skill Kit

一个可复用的 **AI 技能集合库** —— 每个 skill 都是完整的方法论 + Prompt + 工作流，帮助大模型更高效地完成复杂任务。

不是零散的 prompt 片段，而是每个技能都经过 **实战打磨的结构化方案**，可直接嵌入任何 LLM 工作流。

适用于：

- Claude / ChatGPT / Gemini / 开源大模型
- AI Agent 与 Copilot 类助手
- 开发者与知识工作者

> **[English README](README.md)**

---

## 与 Prompt 集合的区别

| | Prompt 集合 | AI Skill Kit |
|--|--|--|
| 结构 | 一句话 prompt | 方法论 + 框架 + 示例 |
| 复用性 | 复制粘贴 | 模块化，可嵌入任意工作流 |
| 质量控制 | 社区提交 | 每个 skill 经过测试迭代 |
| 覆盖范围 | 通用任务 | 领域深度技能 |

---

## 技能分类

```
ai-skill-kit/
├── ai-engineering/     # RAG、Agent、Prompt、LLM 调试
├── career/             # 面试、简历、能力画像
├── analysis/           # 决策、产品战略、深度分析
├── learning/           # 结构化学习路径、主题分析
├── creative/           # 写作、插图、SVG 生成
├── development/        # 测试、评估、调试
└── workflow/           # 自动化、统计、周报
```

---

## 技能清单

### AI 工程

| 技能 | 说明 |
|------|------|
| [rag-evaluator](ai-engineering/rag-evaluator) | 诊断 RAG 管道在检索、生成和一致性层的问题 |
| [prompt-optimizer](ai-engineering/prompt-optimizer) | 定位 Prompt 失败根因并进行结构化修复 |
| [agent-designer](ai-engineering/agent-designer) | 设计 ReAct / Plan-Execute / Multi-Agent 架构，含失败处理 |
| [llm-debugger](ai-engineering/llm-debugger) | 调试生产环境 LLM 应用：API 错误、限流、Token 溢出、流式传输 |
| [vector-db-guide](ai-engineering/vector-db-guide) | 向量数据库选型与使用：Chroma、Milvus、pgvector、Qdrant 对比 |
| [langchain-patterns](ai-engineering/langchain-patterns) | LangChain 核心模式：LCEL、RAG Chain、Memory、Agents 及实战代码 |
| [ai-solution-designer](ai-engineering/ai-solution-designer) | 从场景评估、架构设计到风险和 ROI 分析的 AI 方案设计 |

### 求职

| 技能 | 说明 |
|------|------|
| [mock-interview](career/mock-interview) | 基于简历 + JD 生成高价值面试题与参考答题框架 |
| [job-seeker-resume-cn](career/job-seeker-resume-cn) | 中文简历优化，适配主流招聘平台算法策略 |
| [ai-job-transition-resume](career/ai-job-transition-resume) | AI 工程师 / AI 售前转型简历优化 |
| [ai-engineer-interviewer](career/ai-engineer-interviewer) | AI 工程师岗位技术面试模拟与评估 |
| [interview-sparring](career/interview-sparring) | 诊断式面试陪练，动态识别薄弱环节并针对性辅导 |
| [capability-miner](career/capability-miner) | 从项目记录和 Git 历史中提取结构化能力画像 |

### 分析

| 技能 | 说明 |
|------|------|
| [product-analysis](analysis/product-analysis) | 多维度产品战略分析（用户 / 方案 / 商业 / 竞争 / 风险） |
| [decision-tree](analysis/decision-tree) | 结构化决策框架，输出明确建议 |
| [deep-analysis](analysis/deep-analysis) | 多视角自辩论迭代：生成 → 批判 → 优化，循环至评分 ≥ 8 |

### 学习

| 技能 | 说明 |
|------|------|
| [learn-anything](learning/learn-anything) | 为任何技术或技能生成结构化学习路径 |
| [atdf-analyzer](learning/atdf-analyzer) | 使用 8 维 ATDF 框架系统分析 AI 技术主题 |

### 创作

| 技能 | 说明 |
|------|------|
| [article-illustrator](creative/article-illustrator) | 为文章和内容生成高质量 SVG 品牌插图 |
| [article-writer](creative/article-writer) | 从笔记、大纲或草稿生成结构化文章 |
| [svg-generator](creative/svg-generator) | 以沟通目标为导向的 SVG 图形生成 |
| [svg-to-png](creative/svg-to-png) | SVG 转 PNG，支持多种工具回退方案 |
| [knowledge-viz](creative/knowledge-viz) | 知识动态化引擎 — 将抽象概念转化为交互式深色主题 HTML 体验页面 |
| [iceberg-knowledge-map](creative/iceberg-knowledge-map) | 冰山知识地图 — 水面以上线性主线、下方分层下潜、底部关联网络的三维知识可视化 |
| [frontend-design](creative/frontend-design) | 独特、生产级前端界面设计，规避千篇一律的 AI 美学 |

### 开发

| 技能 | 说明 |
|------|------|
| [add-tests](development/add-tests) | 为已有代码添加单元测试，识别可测试函数并确保全部通过 |
| [test-audit](development/test-audit) | 全维度测试审计：单元/API/组件/安全/集成/E2E 六维覆盖分析与自动补齐 |
| [eval-debug](development/eval-debug) | 分析面试 JSONL 文件，调试模型质量和程序逻辑 |
| [rag-eval](development/rag-eval) | 分析 RAG 实验结果，解读指标，识别异常 |

### 工作流

| 技能 | 说明 |
|------|------|
| [cc-stats](workflow/cc-stats) | 生成 Claude Code 使用统计和生产力洞察 |
| [claude-scheduler](workflow/claude-scheduler) | 使用 macOS launchd 调度 Claude Code 定时任务 |
| [retro](workflow/retro) | 分析近期对话，识别可自动化的重复操作 |
| [weekly-output](workflow/weekly-output) | 结合 BASB、Zettelkasten、T 型、GTD 框架合成周报 |
| [weekly-report](workflow/weekly-report) | 项目周报单页 PNG + Markdown 文字版，给领导/同事汇报用 |

---

## 使用方法

每个技能文件夹包含一个 `SKILL.md`，里面是完整的 prompt 和方法论。使用步骤：

1. 打开目标技能文件夹中的 `SKILL.md`
2. 将 prompt 复制到你的 LLM 对话中
3. 按结构化流程操作

---

## License

MIT
