# AI Skills · 开发任务追踪

> 记录 Skill 开发状态，为持续迭代留痕。

---

## Skill 开发状态

### AI Engineering（核心，对应 AI 工程师面试考点）

| Skill | 状态 | SKILL.md | README 示例 | 备注 |
|-------|------|----------|------------|------|
| rag-evaluator | ✅ 已创建 | ✅ | ❌ 待补 | 覆盖 RAG 全链路诊断 + RAGAS 指标 |
| prompt-optimizer | ✅ 已创建 | ✅ | ❌ 待补 | 5 种失效根因 + 修复工具箱 |
| agent-designer | ✅ 已创建 | ✅ | ❌ 待补 | ReAct/Plan-Execute/Multi-Agent + 失效模式 |
| llm-debugger | ✅ 已创建 | ✅ | ❌ 待补 | 全链路调试 + 生产监控 SOP |
| vector-db-guide | ✅ 已创建 | ✅ | ❌ 待补 | Chroma/Milvus/pgvector 选型 + 代码 |
| langchain-patterns | ✅ 已创建 | ✅ | ❌ 待补 | LCEL/RAG/Memory/Agent 完整代码 |
| ai-solution-designer | ✅ 已创建 | ✅ | ❌ 待补 | 售前+工程双视角方案设计 |

### Career（职业发展）

| Skill | 状态 | SKILL.md | README 示例 | 备注 |
|-------|------|----------|------------|------|
| job-seeker-resume-cn | ✅ 已上线 | ✅ | ✅ | 中文简历优化 |
| ai-job-transition-resume | ✅ 已上线 | ✅ | ✅ | AI 岗位转型简历 |
| mock-interview | ✅ 已创建 | ✅ | ❌ 待补 | 模拟面试 + 回答框架 |

### Business / Thinking / Learning

| Skill | 状态 | SKILL.md | README 示例 | 备注 |
|-------|------|----------|------------|------|
| product-analysis | ✅ 已创建 | ✅ | ❌ 待补 | 产品策略 5 层拆解 |
| decision-tree | ✅ 已创建 | ✅ | ❌ 待补 | 结构化决策，给明确推荐 |
| deep-analysis | ✅ 已上线 | ✅ | ❌ 待补 | Self-Debate 多视角迭代 |
| learn-anything | ✅ 已上线 | ✅ | ✅ | 学习路径生成 |

### Creative / Utility

| Skill | 状态 | SKILL.md | README 示例 | 备注 |
|-------|------|----------|------------|------|
| article-illustrator | ✅ 已上线 | ✅ | ✅ | 文章配图 SVG |
| article-writer | ✅ 已上线 | ✅ | ✅ | 结构化文章生成 |
| svg-generator | ✅ 已上线 | ✅ | ✅ | SVG 生成工作流 |
| svg-to-png | ✅ 已上线 | ✅ | ✅ | SVG 转 PNG |

---

## 待办任务

### 高优先

- [ ] **补 README 示例**：AI Engineering 7 个 Skill 各补一个真实使用示例
  - 示例格式：触发语句 → 输出片段（截图或文字）
  - 优先补：`rag-evaluator`、`prompt-optimizer`、`agent-designer`（面试最常用）

- [ ] **`mock-interview` 上线**：推送到 GitHub，验证在 Claude Code 中可正常触发

### 中优先

- [ ] **补充 Skill：`mcp-server-guide`**
  - MCP 协议原理 + Python 实现 + 常见 Server 类型
  - 对应 JD 加分项，与 ai-skills 生态契合

- [ ] **补充 Skill：`code-reviewer-ai`**
  - 专注 AI 应用代码审查：Prompt 注入风险/Token 效率/错误处理/流式实现
  - 可结合 Speakeasy 代码做示例

### 低优先

- [ ] **Skill 分类重组**：AI Engineering 已经是主体，考虑在 README 里突出这个方向
- [ ] **中文版 README**：当前 README 英文，考虑加中文说明吸引国内用户

---

## 已完成里程碑

| 日期 | 里程碑 |
|------|--------|
| 2026-03-18 | AI Engineering 方向 7 个 Skill 全部创建（rag/prompt/agent/debug/vectordb/langchain/solution）|
| 2026-03-18 | Career/Business 方向补充 mock-interview、product-analysis、decision-tree |
| 2026-03-18 | GitHub README 全面更新，Skill 列表与实际仓库对齐 |
| 2026-03-17 | deep-analysis Self-Debate Skill 发布 |
| 之前 | 基础 Skills 上线（resume/learn/article/svg 系列）|
