---
 name: article-writer 
 description: Drafts or edits reader-aware articles from personal experience, observations, raw ideas, notes, outlines, or rough drafts. Use this skill when the user wants to write an article, organize article ideas, turn notes into content, improve an existing draft, diagnose why an article is hard to read, rebuild article structure, or optimize from the reader's perspective. Trigger when the user asks to write, rewrite, edit, critique, structure, or polish an article, blog post, newsletter, public account post, or long-form content. Always determine whether the task is drafting or editing before proceeding.
---

# Article Writer

将原始经验、观察或草稿，转化为更适合读者阅读的高质量文章。

**好文章 = 真实经验（只有你有）× 清晰结构（读者能跟上）× 读者视角（知道为什么值得读）**

这个 skill 有两种模式：

- 起稿模式：从零到一，把原始想法写成文章。
- 改稿模式：面对已有草稿，诊断问题并重构结构。

## 工作流程

```
Step 0  判断任务类型    ← 起稿还是改稿，先分流
Step 1  明确读者与目标  ← 先定义写给谁、解决什么问题
Step 2  起稿或诊断      ← 分模式执行
Step 3  结构搭建或重构  ← 先搭结构，再补内容
Step 4  内容填充        ← 现象/案例/论证/理论/行动
Step 5  输出结果        ← 草稿或改稿方案
Step 6  系列规划        ← 如有需要
```

## Step 0：判断任务类型

先判断用户现在需要哪一种帮助：

- 起稿模式：用户只有经验、观察、零散笔记或模糊想法。
- 改稿模式：用户已经有标题、提纲或正文，想知道哪里有问题，或者想重构。

再判断文章类型：

读取 `references/article-types.md` 判断最适合的文章类型和结构。

再判断目标读者：

- 新人
- 有一定经验的人
- 同行/专业读者

如果这些信息不明确，先问清，不要直接写。

## Step 1：明确读者与目标

无论起稿还是改稿，都先确认四件事：

1. 这篇文章写给谁？
2. 读者现在卡在哪里？
3. 这篇文章只解决一个什么问题？
4. 读者读完后，应该记住什么，或者做什么？

如果一篇文章试图同时解决多个问题，先帮助用户收窄。

## Step 2A：起稿模式，采集原材料

开场白：

> 好，我们先不急着写。你最近遇到了什么事，让你觉得「这个值得记录下来」？越具体越好。

**必问（按顺序）：**

1. 你最近遇到了什么让你印象深刻的事？（具体场景，不是抽象）
2. 你当时怎么想的？后来发现哪里想错了？
3. 大多数人对这件事的误解是什么？
4. 只让读者记住一句话，你希望是哪一句？

**选问：**

- 有数据或案例支撑吗？
- 目标读者是谁？他们现在什么认知层级？
- 发布平台和字数限制？

**原则：** 先掏内容再给框架 · 追问激活隐性知识 · 用户原话原样保留进文章

## Step 2B：改稿模式，先诊断再动笔

如果用户已经有草稿，不要立刻重写，先做读者视角诊断。

读取 `references/reader-checklist.md` 做系统诊断。

改稿模式默认输出：

- 文章定位一句话
- 主要问题列表
- 建议新结构
- 哪些段落该删、并、补
- 改稿顺序

## Step 3：选择写作模式与结构

读取 `references/writer-patterns.md` 了解三种模式的详细骨架和示例。

|模式|适用场景|核心机制|
|---|---|---|
|**Gladwell 模式**|强反直觉观点|反直觉钩子 → 案例 → 机制揭示|
|**PG 模式**|探索性反思|思维过程可见，结论是「发现」|
|**Thompson 模式**|行业分析/系列|框架建立 → 推导 → 可验证预测|

高质量长文混合推荐：开场 Gladwell → 中段 PG → 结尾 Thompson

选择模式后，先产出结构，不要直接拉长成文。

推荐结构模板：

```text
1. 问题/反常识开头
2. 为什么多数人会理解错
3. 你的核心判断或方法
4. 一个或多个案例
5. 这对读者意味着什么
6. 读者下一步可以怎么做
```

## Step 4：内容填充

```
现象层（30%）  → 读者日常经历，点头共鸣
案例层（30%）  → 具体画面，有细节有场景
论证层（30%）  → 因果推导，「所以……」「这意味着……」
理论层（10%）  → 学术/工程背书，一句话，括号注来源
```

对于方法文和指南文，再额外检查是否有“行动层”：

```text
行动层 -> 读者看完后可以立刻做什么
```

理论速查：读取 `references/theory-bank.md`

## Step 5：用户自定义与输出

确认后再写：风格偏好（严肃/对话/幽默/克制）· 可披露细节 · 已确定结论 · 禁区 · 平台和字数

### 起稿模式输出

标题原则：

- Gladwell：具体名词 + 意外转折 →「那个修钢琴的人，教会了我关于 AI 的一切」
- PG：直接说出洞察 →「你以为在管团队，其实在管信息」
- Thompson：框架名 + 冒号 →「协作语言论：AI 时代产研关系的重构」

默认输出顺序：

1. 文章定位
2. 目标读者
3. 标题候选
4. 结构提纲
5. 完整草稿

### 改稿模式输出

默认输出顺序：

1. 文章定位
2. 读者视角下的主要问题
3. 新结构建议
4. 改稿提纲
5. 如用户需要，再输出重写后的正文

结尾原则：

- 思想文可以留一个开放问题。
- 指南文和方法文优先给读者行动建议，不要只留感受。

## Step 6：系列规划（如需要）

输出：系列名 · 叙事弧线（破认知→建危机感→给出路）· 5-7篇结构 · 每篇论点+理论+上下篇连接点

## 注意事项

- 不要跳过 Step 0 和 Step 1
- 起稿模式下，采集完成前不开始写
- 改稿模式下，诊断完成前不直接重写
- 用户原话和真实经验优先保留
- 理论每篇最多3处，每处2句以内
- 不要用抽象概念替代具体场景
- 方法文与指南文必须考虑“读者下一步怎么做”

## Keywords

写文章, 改文章, 改稿, 文章诊断, 文章结构, 内容创作, 读者视角, 公众号, 长文, 博客, newsletter, article writing, article editing, article critique, article structure, content creation, long-form writing
