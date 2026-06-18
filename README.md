# AI Skill Kit

A curated collection of reusable, structured **AI skills** — each is a complete methodology + prompt + workflow that helps LLMs perform complex tasks more effectively.

Not just prompt snippets. Each skill is a **battle-tested playbook** with clear structure, ready to plug into any LLM workflow.

Designed for:

- Claude / ChatGPT / Gemini / Open-source LLMs
- AI Agents & Copilot-style assistants
- Developers and knowledge workers

> **[中文版 README](README_CN.md)**

---

## What Makes This Different

| | Prompt Collections | AI Skill Kit |
|--|--|--|
| Structure | One-liner prompts | Methodology + framework + examples |
| Reusability | Copy-paste | Modular, plug into any workflow |
| Quality control | Community contributed | Each skill tested and iterated |
| Scope | Generic tasks | Domain-specific deep skills |

---

## Skill Categories

```
ai-skill-kit/
├── ai-engineering/     # RAG, Agent, Prompt, LLM debugging
├── career/             # Interview, resume, capability profiling
├── analysis/           # Decision making, product strategy, deep analysis
├── learning/           # Structured learning paths, topic analysis
├── creative/           # Writing, illustration, SVG generation
├── development/        # Testing, evaluation, debugging
└── workflow/           # Automation, statistics, weekly review
```

---

## Skill Index

### AI Engineering

| Skill | Description |
|------|------|
| [rag-evaluator](ai-engineering/rag-evaluator) | Diagnose RAG pipeline issues across retrieval, generation, and consistency layers |
| [prompt-optimizer](ai-engineering/prompt-optimizer) | Identify root causes of prompt failures and apply structured fixes |
| [agent-designer](ai-engineering/agent-designer) | Design ReAct / Plan-Execute / Multi-Agent architectures with failure handling |
| [llm-debugger](ai-engineering/llm-debugger) | Debug LLM apps in production: API errors, rate limits, token overflow, streaming |
| [vector-db-guide](ai-engineering/vector-db-guide) | Vector DB selection and usage: Chroma, Milvus, pgvector, Qdrant compared |
| [langchain-patterns](ai-engineering/langchain-patterns) | Core LangChain patterns: LCEL, RAG chain, memory, agents with real code |
| [ai-solution-designer](ai-engineering/ai-solution-designer) | Design AI solutions with scenario evaluation, architecture, risk and ROI analysis |

### Career

| Skill | Description |
|------|------|
| [mock-interview](career/mock-interview) | Generate high-value interview questions with answer frameworks based on resume + JD |
| [job-seeker-resume-cn](career/job-seeker-resume-cn) | Chinese resume optimization for general job market with platform algorithm strategies |
| [ai-job-transition-resume](career/ai-job-transition-resume) | Resume optimization for AI engineer / AI pre-sales roles |
| [ai-engineer-interviewer](career/ai-engineer-interviewer) | Conduct technical interviews for AI engineering positions with role-specific evaluation |
| [interview-sparring](career/interview-sparring) | Diagnostic interview practice with dynamic weak-point identification and coaching |
| [capability-miner](career/capability-miner) | Extract structured capability profiles from project memory and Git history |

### Analysis

| Skill | Description |
|------|------|
| [product-analysis](analysis/product-analysis) | Multi-dimensional product strategy analysis (user / solution / business / competition / risk) |
| [decision-tree](analysis/decision-tree) | Structured decision making with explicit recommendations |
| [deep-analysis](analysis/deep-analysis) | Multi-perspective Self-Debate: generate, critique, refine, loops until score >= 8 |

### Learning

| Skill | Description |
|------|------|
| [learn-anything](learning/learn-anything) | Structured learning path for any technology or skill |
| [atdf-analyzer](learning/atdf-analyzer) | Systematically analyze AI topics using 8-dimensional ATDF framework |

### Creative

| Skill | Description |
|------|------|
| [article-illustrator](creative/article-illustrator) | SVG illustrations for articles and visual communication |
| [article-writer](creative/article-writer) | Structured article generation from notes, outlines, or rough content |
| [svg-generator](creative/svg-generator) | User-goal-first SVG generation workflow |
| [svg-to-png](creative/svg-to-png) | Reliable SVG to PNG conversion with tool fallbacks |
| [knowledge-viz](creative/knowledge-viz) | Knowledge Dynamization Engine — turn abstract concepts into interactive dark-themed HTML experiences |
| [iceberg-knowledge-map](creative/iceberg-knowledge-map) | Render any knowledge domain as an interactive iceberg: linear main-line on the surface, layered deep-dives below, relation graph at the bottom |
| [frontend-design](creative/frontend-design) | Distinctive, production-grade frontend interfaces that avoid generic AI aesthetics |

### Development

| Skill | Description |
|------|------|
| [add-tests](development/add-tests) | Add unit tests to existing code, identify testable functions, and ensure all tests pass |
| [test-audit](development/test-audit) | Full-dimension test audit (React/Next.js): Unit/API/Component/Security/Integration/E2E coverage analysis and auto-generation |
| [ok-testaudit-nuxt](development/ok-testaudit-nuxt) | Test-coverage audit for Nuxt 3 + Vitest + Playwright frontends — gap analysis and missing-test generation aligned to real Nuxt conventions |
| [ok-testaudit-server](development/ok-testaudit-server) | Test-coverage audit for Spring Boot + Spring AI backends — multi-tenant isolation & LLM tool-chain gaps, JUnit/Mockito/Testcontainers/WireMock |
| [ok-itest](development/ok-itest) | Generate executable integration-test specs, skeletons, and PR reports for Spring Boot + Spring AI (WireMock + Testcontainers + tenant isolation) |
| [eval-debug](development/eval-debug) | Analyze interview JSONL files for model quality and program logic debugging |
| [rag-eval](development/rag-eval) | Analyze RAG experimental results, interpret metrics, and identify anomalies |

### Workflow

| Skill | Description |
|------|------|
| [cc-stats](workflow/cc-stats) | Generate Claude Code usage statistics and productivity insights |
| [claude-scheduler](workflow/claude-scheduler) | Schedule Claude Code tasks using macOS launchd for persistent background execution |
| [retro](workflow/retro) | Analyze recent conversations to identify repeated operations for automation |
| [weekly-output](workflow/weekly-output) | Synthesize weekly notes using BASB, Zettelkasten, T-shape, and GTD frameworks |
| [weekly-report](workflow/weekly-report) | Single-page weekly status report PNG + Markdown for stakeholder reporting |

---

## Usage

Each skill folder contains a `SKILL.md` with the complete prompt and methodology. To use a skill:

1. Open the `SKILL.md` file in the skill folder
2. Copy the prompt into your LLM conversation
3. Follow the structured workflow

---

## License

MIT
