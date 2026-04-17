# Viz Framework — Component Reference

Complete CSS + JS reference for the 9 knowledge visualization components.
All components are zero-dependency, dark-themed, and mobile-responsive.

## Theme Variables (CSS)

Override `:root` to customize colors globally:

```css
:root {
  --viz-bg:      #0f1117;   /* Background */
  --viz-card:    #1a1d28;   /* Card background */
  --viz-border:  #2a2d3a;   /* Borders */
  --viz-accent:  #6c63ff;   /* Primary accent (purple) */
  --viz-green:   #00d2a0;   /* Success / positive */
  --viz-orange:  #ff9f43;   /* Warning / question */
  --viz-red:     #ff6b6b;   /* Error / overflow */
  --viz-blue:    #4ecdc4;   /* Info / secondary */
  --viz-text:    #e4e6eb;   /* Body text */
  --viz-dim:     #8b8fa3;   /* Muted text */
  --viz-radius:  16px;      /* Border radius */
  --viz-radius-sm: 8px;
  --viz-font: -apple-system, "PingFang SC", "Microsoft YaHei", sans-serif;
}
```

## Base HTML

```html
<body class="viz-body">
  <!-- body needs viz-body class for reset + base styles -->
</body>
```

## Layout Classes

| Class | Purpose |
|-------|---------|
| `.viz-section` | Page section (max-width 960px, centered, padded) |
| `.viz-h1` | Page title. Use `<span>` for accent highlight |
| `.viz-h2` | Section title with accent underline |
| `.viz-subtitle` | Subtitle text (muted) |
| `.viz-desc` | Description paragraph (muted, max-width 680px) |
| `.viz-hint` | Small hint text (centered, muted) |
| `.viz-demo` | Generic demo wrapper (card background + border) |
| `.viz-demo-header` | Flex header inside demo (title + button) |
| `.viz-footer` | Page footer (centered, muted) |

## Button Classes

| Class | Style |
|-------|-------|
| `.viz-btn` | Base button |
| `.viz-btn-primary` | Accent background, white text |
| `.viz-btn-outline` | Transparent, border, hover accent |

## Tag Classes

| Class | Color |
|-------|-------|
| `.viz-tag` | Base tag (inline pill) |
| `.viz-tag-accent` | Purple |
| `.viz-tag-green` | Green |
| `.viz-tag-orange` | Orange |
| `.viz-tag-red` | Red |
| `.viz-tag-blue` | Blue |

---

## Component 1: VizNav

Sticky top navigation with scroll-based active highlighting.

```js
new VizNav('#nav', {
  links: [
    { label: '概述', target: '#intro' },
    { label: '对比', target: '#compare' }
  ],
  offset: 100  // scroll detection offset (px)
});
```

**HTML:** `<nav class="viz-nav" id="nav"></nav>`

**Methods:** `.destroy()` — remove scroll listener

---

## Component 2: VizFadeIn

Scroll-triggered fade-in animation.

```js
VizFadeIn.init({
  selector: '.viz-fade-in',  // target elements
  threshold: 0.15            // visibility threshold
});
```

**HTML:** Add `viz-fade-in` class to any element. It fades in when scrolled into view.

**Shortcut:** `VizFramework.autoInit()` initializes both Nav and FadeIn.

---

## Component 3: VizRace

Two-lane race animation comparing parallel processing speeds.

```js
new VizRace('#container', {
  totalTasks: 256,       // total task blocks
  stepDelay: 200,        // ms between batches
  btnText: '开始计算',    // button label
  lanes: [
    { label: 'CPU - 8核',  cores: 8,  color: 'var(--viz-accent)' },
    { label: 'GPU - 64核', cores: 64, color: 'var(--viz-green)' }
  ],
  onComplete: (laneIndex, timeMs) => {}  // callback
});
```

**Methods:** `.start()` — trigger race programmatically

---

## Component 4: VizCapacity

Container capacity demo with overflow detection.

```js
new VizCapacity('#container', {
  containers: [
    { id: '4090', label: 'RTX 4090', capacity: 24, unit: 'GB' },
    { id: 'a100', label: 'A100',     capacity: 40, unit: 'GB' }
  ],
  items: [
    { label: 'Qwen-7B',   size: 14,  color: '#6c63ff' },
    { label: 'Llama-13B', size: 26,  color: '#ff9f43' },
    { label: 'Llama-70B', size: 140, color: '#ff6b6b' }
  ],
  clearText: '清空'
});
```

**Methods:** `.loadItem(item)`, `.clear()`

---

## Component 5: VizConveyor

Animated conveyor belt showing throughput differences.

```js
new VizConveyor('#container', {
  lanes: [
    {
      label: 'RTX 4090 — 1.0 TB/s',
      speed: 1.5,              // pixels per frame (higher = faster)
      color: 'var(--viz-green)',
      packets: 6,              // number of data packets
      desc: '每秒 1 万亿字节'   // subtitle
    },
    {
      label: 'A100 — 1.6 TB/s',
      speed: 2.5,
      color: 'var(--viz-accent)',
      packets: 9,
      desc: '快 60%'
    }
  ]
});
```

**Methods:** `.destroy()` — cancel animation frames

---

## Component 6: VizPipeFlow

Pipe flow animation between two endpoints.

```js
new VizPipeFlow('#container', {
  maxBarWidth: 300,  // max width of speed comparison bar
  pairs: [
    {
      title: '2 × RTX 4090',
      desc: '只能走 PCIe',
      left:  { label: '4090', sub: '24GB', color: 'var(--viz-green)' },
      right: { label: '4090', sub: '24GB', color: 'var(--viz-green)' },
      pipeClass: 'slow',   // 'slow' (2s cycle) or 'fast' (0.3s cycle)
      speed: 64,
      unit: 'GB/s'
    },
    {
      title: '2 × A100',
      desc: 'NVLink 高速',
      left:  { label: 'A100', sub: '40GB', color: 'var(--viz-accent)' },
      right: { label: 'A100', sub: '40GB', color: 'var(--viz-accent)' },
      pipeClass: 'fast',
      speed: 600,
      unit: 'GB/s'
    }
  ]
});
```

---

## Component 7: VizDecisionTree

JSON-driven decision tree with recursive branching.

```js
new VizDecisionTree('#container', {
  root: {
    question: '你要跑多大的模型？',   // question node (orange border)
    branches: [
      {
        label: '7B及以下',             // branch label
        answer: '单张 RTX 4090',       // answer node (green border)
        detail: '24GB 足够'            // optional subtitle
      },
      {
        label: '13B~30B',
        question: '预算充裕？',         // nested question
        branches: [
          { label: '是', answer: 'A100-40G' },
          { label: '否', answer: '2×4090 + 量化' }
        ]
      },
      { label: '70B+', answer: '多卡 A100/H100', detail: 'NVLink 必需' }
    ]
  }
});
```

**Node types:**
- `question` property → orange-bordered question node
- `answer` property → green-bordered answer node (leaf)
- `detail` property → optional small subtitle

---

## Component 8: VizCompareTable

Styled comparison table with cell highlighting.

```js
new VizCompareTable('#container', {
  headers: ['参数', '方案A', '方案B', '结论'],
  rows: [
    {
      cells: ['显存', '48GB', '<b>40GB</b>', 'A 更大但不连续'],
      highlight: [1]  // indices of cells to highlight (green + bold)
    },
    {
      cells: ['价格', '<b>¥28k</b>', '¥60k', 'A 便宜一半'],
      highlight: [1, 3]
    }
  ]
});
```

**HTML alternative:** Use `<table class="viz-table">` with `class="highlight"` on `<td>`.

---

## Component 9: VizCards

Responsive card grid layout.

```js
new VizCards('#container', {
  cards: [
    {
      tag: 'CPU',                    // optional tag text
      tagColor: 'accent',           // accent|green|orange|red|blue
      title: '总经理',
      desc: '擅长复杂逻辑<br>支持 HTML',
      extra: '<div>Custom HTML</div>'  // optional extra content
    }
  ]
});
```

**HTML alternative:** Use `.viz-card-row > .viz-card` structure directly.

---

## Auto-Init Helper

```js
VizFramework.autoInit({
  navOffset: 100,
  fadeSelector: '.viz-fade-in',
  fadeThreshold: 0.15
});
```

Initializes VizNav (scroll spy) and VizFadeIn automatically.

---

## CSS Keyframes

| Animation | Used By | Effect |
|-----------|---------|--------|
| `vizPulse` | VizRace workers | Purple pulse while working |
| `vizPipeFlow` | VizPipeFlow | Data flowing through pipe |

## Responsive Breakpoint

At `max-width: 640px`:
- Sections get reduced padding
- All flex containers stack vertically
- Font sizes reduce
- Nav gets compact padding
