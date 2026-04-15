---
name: svg-generator
description: Generates SVG graphics from the user's communication goal instead of jumping straight to drawing. Use this skill when the user wants to create an SVG, make a diagram, generate a cover, visualize an idea, turn text into an infographic, draw a flowchart, framework, comparison chart, quote card, social graphic, or lightweight web illustration. Trigger on requests like 做一个SVG, 画个图, 生成封面图, 可视化这个观点, make an SVG, create a diagram, generate a vector graphic, or turn this content into a visual.
---

# SVG Generator

先不要急着画。先判断这张 SVG 为什么存在。

**好 SVG = 使用场景明确 x 单图目标单一 x 信息层级清晰 x 输出可复用**

很多 SVG 之所以难用，不是因为不会写 `<svg>`，而是因为一开始没有想清楚：

- 用户为什么需要这张图
- 这张图是拿来解释、传播、装饰，还是转化
- 读者第一眼必须看到什么

## Step 1：先想“为什么要这张 SVG”

先判断任务属于哪一类：

|类型|用户真正想要的|典型结果|
|---|---|---|
|**解释型**|把复杂内容讲清楚|流程图、框架图、架构图|
|**传播型**|让一条观点更容易被看到和转发|封面图、金句卡、对比图|
|**产品型**|用于界面、网页、文档|插画、图标、hero graphic|
|**数据型**|让数字关系一眼可见|条形图、对比图、时间线|

如果用户没有说明，优先反推这四件事：

1. 这张图服务于什么场景？公众号、PPT、网页、社媒、文档？
2. 看图的人是谁？第一次接触这个主题的人，还是专业读者？
3. 看完后希望对方理解什么、记住什么、做什么？
4. 这张图是主角还是配角？是正文核心图，还是辅助视觉？

没有这些信息时，不要直接开始复杂绘制。先收窄目标。

## Step 2：定义“这张图只解决一个问题”

把需求压缩成一句话：

```text
这张 SVG 的任务是：帮助[谁]在[场景]里，快速理解/记住/比较[某个核心信息]。
```

如果一句话里出现两个以上动作，比如“既要解释原理，也要做封面，还要显得高级”，先拆开，不要混成一张图。

## Step 3：选择最合适的 SVG 类型

读取 `references/svg-types.md`，按任务选图型。

快速判断：

- 有步骤、因果、状态变化 -> 流程图
- 有左右差异、前后变化 -> 对比图
- 有层级、模块、系统边界 -> 框架图
- 有一句核心观点要传播 -> 金句卡
- 是文章或系列首图 -> 封面图
- 是网页或产品配图 -> 轻插画 / hero graphic

原则：能用结构图，就不要硬做插画。解释任务优先结构清晰，不优先“好看”。

## Step 4：写视觉 brief，再生成

先用这个最小 brief：

```text
目标：这张图要传达什么
场景：发布在哪里
读者：谁会看
类型：封面 / 对比 / 流程 / 框架 / 金句 / 插画
尺寸：如 750x1050, 1200x630, 1600x900
必须出现：标题、关键词、数字、品牌元素
不能出现：过多装饰、复杂渐变、过长段落
```

然后再生成 SVG。

如果是代码生成，默认：

- 先用基本几何形状搭信息结构
- 文字层级先排清楚，再补装饰
- 保持文本可编辑，不要把文字转路径
- 优先单文件、纯 SVG，可直接预览和修改

## Step 5：默认设计规则

- 一张图只保留一个视觉焦点
- 标题与正文至少拉开一个明显字号层级
- 四边留白充足，避免“内容塞满”
- 一般不超过 3 个主色
- 装饰元素不抢信息主体
- 缩小到手机宽度时，核心信息仍可读

## Step 6：输出方式

默认输出：

1. 一句话任务定义
2. 选定图型和理由
3. SVG 代码或 SVG 文件
4. 简短自查

如果用户要多张图，按顺序一张一张做，先确认第一张风格和信息密度，再批量扩展。

## 什么时候读参考文件

- 需要判断图型时 -> 读取 `references/svg-types.md`
- 需要快速收集需求时 -> 读取 `references/svg-brief-template.md`

## 注意事项

- 不要一上来就问配色和风格，先问任务和使用场景
- 不要把一张图做成“海报 + 说明书 + 数据图”的混合体
- 解释型图优先准确，传播型图优先聚焦
- 若用户只说“做个 SVG”，默认先补全任务定义，再开始画

## Keywords

SVG, svg, 矢量图, 配图, 插画, 封面图, 流程图, 对比图, 框架图, 金句卡, 可视化, 信息图, hero graphic, diagram, infographic, vector graphic
