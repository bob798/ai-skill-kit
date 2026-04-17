---
name: knowledge-viz
description: Knowledge Dynamization Engine — transforms abstract knowledge on any topic into interactive, dark-themed HTML visualization pages. Not a charting tool, but a system for turning "knowledge you have to think about" into "experiences you instantly feel." Use when the user wants to explain a concept visually, create an interactive tutorial, build a comparison demo, make a technical topic accessible to non-technical audiences, or generate a shareable single-file HTML explainer. Trigger on requests like 知识可视化, 做个可视化, 动态展示, 交互式讲解, 帮我解释, visualize this concept, make it interactive, explain with animations.
---

# Knowledge Dynamization Engine

知识动态化引擎 — 把抽象知识转化为可交互的具身体验。

**核心理念：不是画图表，而是让知识"动起来"。**

## Philosophy: Three-Layer Progression

Every knowledge presentation has three layers. You can stop at any layer:

| Layer | Form | How audience learns | Example |
|-------|------|-------------------|---------|
| **1. Static text** | Docs / PPT | Read → Understand → Imagine | "GPU has thousands of cores for parallel computing" |
| **2. Static visuals** | Tables / Charts | See numbers → Compare → Judge | 4090 vs A100 spec table |
| **3. Dynamic interaction** | Animation / Interactive | Directly feel → Build intuition | Watch 8 cores vs 64 cores race — **you get it without thinking** |

The key difference: static knowledge requires the reader to "simulate" in their head. Dynamic visualization **externalizes** that simulation.

## 9 Knowledge Presentation Components

Each component maps to a cognitive pattern:

| Component | Knowledge Pattern | Best For |
|-----------|------------------|----------|
| **VizRace** | Speed / efficiency gap | "How much faster is A than B" |
| **VizCapacity** | Capacity / constraint limits | "Can it fit / is it enough" |
| **VizConveyor** | Throughput / flow rate | "How fast does data flow" |
| **VizPipeFlow** | Channel / connection | "How do two things communicate" |
| **VizDecisionTree** | Conditional / choice | "Which should I pick" |
| **VizCompareTable** | Multi-dimensional comparison | "Who wins on each dimension" |
| **VizCards** | Concept introduction | "What are these things" |
| **VizFadeIn** | Attention guidance | "Look at this first, then that" |
| **VizNav** | Knowledge structure | "What sections exist" |

## Step 1: Knowledge Deconstruction (Cognitive Analysis)

Given a topic, answer three questions internally (do NOT output to user):

1. **What are the core concepts?** — Break into 3–7 key knowledge points
2. **Where is the cognitive bottleneck?** — Which point is hardest to grasp? (abstract, counterintuitive, requires comparison)
3. **Who is the audience?** — Technical people get precise data; non-technical get analogies

## Step 2: Component Selection (Pattern Matching)

Match each knowledge point's cognitive bottleneck to the right component:

- Bottleneck is "how much difference" → **VizRace** or **VizConveyor**
- Bottleneck is "can it fit / is it enough" → **VizCapacity**
- Bottleneck is "which to choose" → **VizDecisionTree**
- Bottleneck is "multi-dimension comparison" → **VizCompareTable**
- Bottleneck is "what is this" → **VizCards**
- Bottleneck is "how things connect" → **VizPipeFlow**

Use at least 3 different components per page, forming a **narrative arc**:

```
Introduction (VizCards) → Dynamic Experience (Race/Capacity/Conveyor) → Decision Summary (Tree/Table)
   "what is it"              "feel the difference"                     "what to choose"
```

## Step 3: Generate the Page

### Technical Stack
- **Zero dependencies** — pure HTML + CSS + JS
- **Dark theme** — professional, eye-friendly
- **Single file** — inline all CSS and JS for easy sharing
- **Responsive** — works on mobile and desktop
- **Chinese-first** — all text in Chinese, technical terms keep English

### Component Implementation Reference

See `references/viz-components.md` for the complete CSS class reference and JS API for all 9 components.

### Page Structure
```html
<body class="viz-body">
  <nav class="viz-nav" id="nav"></nav>

  <section class="viz-section" id="intro">
    <h1 class="viz-h1">Topic <span>Highlight</span></h1>
    <p class="viz-subtitle">One-line description</p>
    <!-- VizCards: introduce core concepts -->
  </section>

  <section class="viz-section" id="demo1">
    <h2 class="viz-h2">Section Title</h2>
    <p class="viz-desc">Everyday analogy for this concept</p>
    <!-- VizRace / VizCapacity / VizConveyor -->
  </section>

  <!-- ... more sections ... -->

  <section class="viz-section" id="summary">
    <!-- VizDecisionTree + VizCompareTable -->
  </section>
</body>
```

### Initialization Pattern
```js
// Each component: new VizXxx('#container', { config })
new VizNav('#nav', { links: [...] });
new VizRace('#race', { totalTasks: 256, lanes: [...] });
new VizCapacity('#cap', { containers: [...], items: [...] });
new VizConveyor('#conv', { lanes: [...] });
new VizPipeFlow('#pipe', { pairs: [...] });
new VizDecisionTree('#tree', { root: { question: '...', branches: [...] } });
new VizCompareTable('#table', { headers: [...], rows: [...] });
new VizCards('#cards', { cards: [...] });
VizFramework.autoInit(); // Nav scroll spy + FadeIn
```

## Step 4: Output Summary

After generating the page, tell the user:
- What interactions the page contains (bullet list)
- The core conclusion in one sentence
- File path for sharing

## Rules

1. **Always inline CSS/JS** — single HTML file, no external dependencies
2. **All text in Chinese** — keep English for technical terms only
3. **Verify data accuracy** — search/research if uncertain
4. **Analogy first** — every abstract concept gets a real-life metaphor
5. **No component bloat** — each component must solve a specific cognitive bottleneck
6. **File naming**: `{topic}-viz.html` in the user's current working directory
7. **Open in browser** after generation using `open` command

## Examples

```
User: Explain GPU basics to a beginner
→ gpu-viz.html: CPU vs GPU race, VRAM capacity buckets, bandwidth conveyor, NVLink pipe, GPU selection decision tree

User: Microservices vs Monolith for tech team
→ microservices-viz.html: deployment complexity table, request chain pipe animation, scaling capacity demo, architecture decision tree

User: How RAG works
→ rag-viz.html: retrieval pipeline conveyor, vector similarity race, context window capacity, tech stack decision tree

User: Compare cloud providers
→ cloud-viz.html: pricing comparison table, performance race, storage capacity demo, selection decision tree
```
