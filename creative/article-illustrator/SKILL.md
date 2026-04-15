---

name: article-illustrator 
description: Generates high-quality SVG illustration assets for articles, series content, and personal IP branding. Delivers production-ready SVG files in a restrained, premium style that avoids generic AI aesthetics. Use this skill for WeChat article covers, knowledge cards, series overview maps, framework visualizations, quote cards, comparison charts, and flow diagrams. Trigger immediately when user says 帮我做配图, 把这个可视化, 做张图, 需要封面, 配图, make an illustration, visualize this, create a diagram, or I need a graphic.
---
# Article Illustrator

将文章内容和框架，转化为高质量、可发布的品牌配图。

**好配图 = 信息密度适中 × 品牌一致性 × 视觉层级清晰**

图不是装饰，是论点的延伸。每张图必须能独立传达一个完整观点。

## Step 1：明确需求

必确认：

1. 这张图要传达的核心信息？（一句话）
2. 图片类型？（见类型库）
3. 用于什么平台？（微信/知乎/小红书/PPT）

选确认：品牌色系 · 是否需要跨图一致性 · 必须出现的文字

## Step 2：选择图片类型

|类型|用于|布局特征|
|---|---|---|
|**封面图**|文章封面、系列第一张|大字留白 + 品牌色侧栏|
|**对比图**|新旧对比、好坏对比|左右分栏，两侧不同底色|
|**流程图**|步骤、机制、因果链|竖向流动 + 箭头连接|
|**框架图**|多维模型、矩阵、层级|几何形状 + 颜色编码|
|**金句卡片**|系列结尾、单独传播|极简大字，大量留白|
|**知识地图**|系列规划、体系全景|分层结构，颜色分域|

快速判断：「封面/第一张」→ 封面图 · 「对比/新旧」→ 对比图 · 「步骤/流程」→ 流程图 · 「框架/模型」→ 框架图 · 「金句/结尾」→ 金句卡片 · 「全景/地图」→ 知识地图

## Step 3：默认品牌系统（暖橙·克制高级）

```javascript
W_ = 750, H_ = 1050        // 微信手机竖屏标准尺寸

O  = '#F26419'             // 品牌橙（克制使用，只用于强调）
BK = '#1C1C1C'             // 近黑（主要文字）
G2 = '#7A7A7A'             // 中灰（次要文字）
G4 = '#E8E8E8'             // 分割线
WH = '#FAF9F6'             // 暖白背景
W  = '#FFFFFF'             // 纯白卡片

// 品牌角标（每张图左上角必须有）
<rect x="40" y="40" width="36" height="4" fill="${O}"/>
<rect x="40" y="40" width="4"  height="36" fill="${O}"/>

// 字体
中文：PingFang SC · 英文/数字：Georgia
```

系列一致性规则：同系列所有图使用相同背景色 + 相同角标位置 + 相同布局模板

## Step 4：生成 SVG

用 Node.js 生成，输出到 `/mnt/user-data/outputs/`。 各类型详细代码模板 → 读取 `references/svg-templates.md`

**代码基础结构：**

```javascript
const fs = require('fs');
const O='#F26419', BK='#1C1C1C', G2='#7A7A7A', G4='#E8E8E8', WH='#FAF9F6', W='#FFFFFF';
const W_=750, H_=1050;

const t = (x,y,s,sz,c,a='start',w='normal') =>
  `<text x="${x}" y="${y}" text-anchor="${a}"
   font-family="'PingFang SC',Georgia,sans-serif"
   font-size="${sz}" fill="${c}" font-weight="${w}">${s}</text>`;

const svg = `<svg width="${W_}" height="${H_}" viewBox="0 0 ${W_} ${H_}"
  xmlns="http://www.w3.org/2000/svg">
  <rect width="${W_}" height="${H_}" fill="${WH}"/>
  <rect x="40" y="40" width="36" height="4" fill="${O}"/>
  <rect x="40" y="40" width="4" height="36" fill="${O}"/>
  <!-- 内容 -->
</svg>`;

fs.writeFileSync('/mnt/user-data/outputs/文件名.svg', svg);
```

## Step 5：视觉质量自查

```
□ 四边留白至少 40px，文字内边距至少 16px
□ 标题字号 > 正文，层级差至少 6px
□ 品牌橙只用于 1-2 处强调
□ 这张图能独立传达核心观点吗？
□ 手机屏幕缩小后主要信息还清晰吗？
```

## 系列配图工作流

每张确认后再生成下一张，顺序： 01 封面图 → 02 核心对比图 → 03 机制/流程图 → 04 框架图 → 05 方法图 → 06 金句卡片

SVG 转 PNG：用浏览器打开 .svg → 右键另存为 / 截图

## 注意事项

- 内容优先于美观，第一目标是传达信息
- 留白是设计的一部分，不要填满所有空间
- 品牌橙克制使用，力量来自稀缺
- 一次生成一张，确认后再生成下一张

## Keywords

配图, 插图, SVG, 封面, 可视化, illustration, diagram, cover, infographic, visual