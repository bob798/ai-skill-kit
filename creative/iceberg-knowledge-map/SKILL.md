---
name: iceberg-knowledge-map
description: |
  构建「冰山知识架构」可视化组件——将任意学科/技术领域的知识体系渲染为交互式三维结构：
  水面以上是干净的学习主线（线性推进），水面以下是按需下潜的冰山（深度分层），
  冰山底部展示知识节点间的关联网络。适用于：课程体系设计、技术栈学习路径、
  知识地图梳理、教学内容可视化。

  触发场景：
  - 用户说「帮我做一个知识地图 / 学习路径 / 知识架构」
  - 用户想「把这个领域的知识可视化」
  - 用户提供了一组有先后关系的概念，想呈现成交互式结构
  - 任何涉及「知识体系 + 可视化 + 初学者友好」的需求
---

# Iceberg Knowledge Map Skill

将知识体系渲染为三维交互结构的 HTML 可视化组件。

---

## 核心设计哲学

书本是一维线性的，但知识本质是多维网状的。本技能将三个维度分离到不同空间，互不干扰：

| 维度 | 承载信息 | 视觉位置 | 出现时机 |
|------|----------|----------|----------|
| **水平轴（主线）** | 节点顺序、学习方向 | 水面以上，永远可见 | 始终 |
| **垂直轴（深度）** | 四层冰山内容 | 水面以下，点击展开 | 下潜后 |
| **关联轴（网络）** | 节点间依赖关系 | 冰山面板底部 | 下潜后，内容之后 |

**关键原则**：主线给方向，冰山给深度，关联给网络感。三者按认知时序依次出现，初学者不会被深度和关联打断主线节奏。

---

## 数据结构

在生成组件前，先将用户提供的知识领域整理为以下结构：

### 节点（nodes）
```js
{
  id: 'unique_id',
  icon: '🎯',          // 单个 emoji，代表该节点性质
  label: '短名',        // ≤4字，显示在圆圈上
  sublabel: '副标题',   // ≤4字，圆圈下方
  tag: '所属层',        // 面板右上角标签
  layers: [            // 冰山四层，顺序固定
    { lv:1, label:'表层 — 核心用法', items:[...] },   // 初学必知
    { lv:2, label:'关联 — 横向延伸', items:[...] },   // 同级概念/工具
    { lv:3, label:'原理 — 底层机制', items:[...] },   // why & how
    { lv:4, label:'历史 / 前沿',     items:[...] },   // 演化与未来
  ]
}
```

每层 items 建议 3-5 条，每条 ≤20 字。

### 边（edges）
```js
['node_a', 'node_b', strength_0_to_1, '关系描述']
// strength: 0.9+ 强依赖，0.6-0.9 中等，0.3-0.6 弱关联
```

---

## HTML 呈现模型

```
[1]   [2]   [3]   [4]   [5]         ← 序号
 ○────○────○────○────○              ← 主线（永远干净）
─ ─ ─ ─ ─ 水面 ─ ─ ─ ─ ─ ─         ← 水面分界线
┌──────────────────────────┐
│ 🎯 节点名 · 副标题    ✕  │        ← 面板 header
├──────────────────────────┤
│ 🌊 表层 — 核心用法   ▶  │        ← l1 最浅蓝
│ 🐬 关联 — 横向延伸   ▶  │        ← l2
│ 🦑 原理 — 底层机制   ▶  │        ← l3
│ 🌑 历史 / 前沿        ▶  │        ← l4 最深蓝
├──────────────────────────┤
│ 知识关联                  │        ← 关联区在最底部
│ [mini辐射图] [强度列表]   │
└──────────────────────────┘
```

**关联放在底部而非顶部**：用户点开节点的第一需求是「这是什么/怎么用」，关联是元认知，适合在了解内容后再看。

---

## 完整代码模板

以下是可直接运行的完整 HTML 组件，替换 `DATA_NODES` 和 `DATA_EDGES` 即可：

```html
<style>
*{box-sizing:border-box;margin:0;padding:0}
.root{font-family:var(--font-sans);padding:1.25rem .75rem 1.75rem;max-width:720px;margin:0 auto}
.path-area{position:relative;padding:1rem 0 .75rem}
.path-line{position:absolute;top:calc(1rem + 26px);left:0;right:0;height:2px;background:var(--color-border-tertiary);z-index:0}
.path-nodes{display:flex;justify-content:space-between;position:relative;z-index:1}
.nw{display:flex;flex-direction:column;align-items:center;gap:6px;cursor:pointer;flex:1}
.nc{width:52px;height:52px;border-radius:50%;border:1.5px solid var(--color-border-secondary);background:var(--color-background-primary);display:flex;flex-direction:column;align-items:center;justify-content:center;transition:all .22s}
.nc .ni{font-size:17px;line-height:1}
.nc .nl{font-size:9px;color:var(--color-text-tertiary);font-weight:500;margin-top:1px}
.nw.active .nc{border-color:#378ADD;border-width:2px;background:var(--color-background-info);transform:scale(1.08)}
.nw:hover:not(.active) .nc{background:var(--color-background-secondary)}
.n-label{font-size:11px;color:var(--color-text-secondary);text-align:center}
.nw.active .n-label{color:#185FA5;font-weight:500}
.n-seq{font-size:10px;color:var(--color-text-tertiary);margin-bottom:2px}
.nw.active .n-seq{color:#378ADD}
.waterline{height:2px;background:linear-gradient(90deg,transparent,rgba(56,139,212,.5) 20%,rgba(56,139,212,.5) 80%,transparent);margin:.5rem 0 0;position:relative}
.waterline::after{content:'水面';position:absolute;right:0;top:-15px;font-size:10px;color:var(--color-text-tertiary);letter-spacing:.06em}
.panel{background:var(--color-background-secondary);border-radius:0 0 12px 12px;overflow:hidden;max-height:0;opacity:0;transition:max-height .4s ease,opacity .3s ease}
.panel.open{max-height:900px;opacity:1}
.panel-header{display:flex;align-items:center;gap:8px;padding:.7rem 1rem .6rem;border-bottom:.5px solid var(--color-border-tertiary)}
.ph-icon{font-size:16px}
.ph-title{font-size:15px;font-weight:500;color:var(--color-text-primary)}
.ph-tag{font-size:11px;color:var(--color-text-tertiary);border:.5px solid var(--color-border-tertiary);border-radius:4px;padding:2px 7px;margin-left:auto}
.ph-close{font-size:13px;color:var(--color-text-tertiary);cursor:pointer;padding:2px 6px;border-radius:4px;transition:background .15s;margin-left:6px}
.ph-close:hover{background:var(--color-background-tertiary)}
.layers-section{padding:.6rem .75rem .75rem;display:flex;flex-direction:column;gap:2px}
.ly{border-radius:8px;overflow:hidden;cursor:pointer}
.ly-head{display:flex;align-items:center;gap:8px;padding:.55rem .8rem;font-size:12px;font-weight:500;user-select:none}
.ly-body{font-size:13px;line-height:1.65;padding:.45rem .8rem .65rem;display:none}
.ly.open .ly-body{display:block}
.ly-body ul{list-style:none;display:flex;flex-direction:column;gap:3px}
.ly-body li{padding-left:12px;position:relative}
.ly-body li::before{content:'·';position:absolute;left:0;opacity:.4}
.chev{margin-left:auto;font-size:9px;transition:transform .2s;opacity:.45}
.ly.open .chev{transform:rotate(90deg)}
.l1{background:#E6F1FB}.l1 .ly-head,.l1 .ly-body{color:#042C53}
.l2{background:#B5D4F4}.l2 .ly-head,.l2 .ly-body{color:#042C53}
.l3{background:#378ADD}.l3 .ly-head,.l3 .ly-body{color:#E6F1FB}
.l4{background:#0C447C}.l4 .ly-head,.l4 .ly-body{color:#B5D4F4}
@media(prefers-color-scheme:dark){
  .l1{background:#042C53}.l1 .ly-head,.l1 .ly-body{color:#B5D4F4}
  .l2{background:#0C447C}.l2 .ly-head,.l2 .ly-body{color:#85B7EB}
  .l3{background:#185FA5}.l3 .ly-head,.l3 .ly-body{color:#E6F1FB}
  .l4{background:#378ADD}.l4 .ly-head,.l4 .ly-body{color:#042C53}
}
.rel-section{padding:.6rem 1rem .75rem;border-top:.5px solid var(--color-border-tertiary)}
.rel-head{font-size:11px;color:var(--color-text-tertiary);letter-spacing:.07em;margin-bottom:.6rem}
.mini-graph-wrap{display:flex;gap:1rem;align-items:center}
.rel-list{flex:1;display:flex;flex-direction:column;gap:5px}
.rel-row{display:flex;align-items:center;gap:7px;cursor:pointer;padding:4px 6px;border-radius:6px;transition:background .15s}
.rel-row:hover{background:var(--color-background-primary)}
.rel-icon{font-size:13px;width:22px;text-align:center}
.rel-name{font-size:12px;font-weight:500;color:var(--color-text-primary);min-width:36px}
.rel-label{font-size:11px;color:var(--color-text-secondary);flex:1}
.rel-bar-wrap{width:48px;height:4px;border-radius:2px;background:var(--color-border-tertiary);overflow:hidden;flex-shrink:0}
.rel-bar{height:100%;border-radius:2px;background:#378ADD;transition:width .4s .1s}
.hint{text-align:center;padding:1.25rem;font-size:13px;color:var(--color-text-tertiary)}
.hint b{color:var(--color-text-secondary);font-weight:500}
</style>

<div class="root">
  <div class="path-area">
    <div class="path-line"></div>
    <div class="path-nodes" id="nodes-el"></div>
  </div>
  <div class="waterline"></div>
  <div class="panel" id="panel">
    <div id="hint-el" class="hint">点击节点 <b>下潜探索</b></div>
    <div id="panel-body" style="display:none"></div>
  </div>
</div>

<script>
// ── 替换以下数据 ──────────────────────────────────
const nodes = DATA_NODES;
const edges = DATA_EDGES;
// ─────────────────────────────────────────────────

function getRelated(id){
  return edges
    .filter(e=>e[0]===id||e[1]===id)
    .map(e=>({otherId:e[0]===id?e[1]:e[0],strength:e[2],label:e[3]}))
    .sort((a,b)=>b.strength-a.strength);
}

// build main line
const nodesEl=document.getElementById('nodes-el');
nodes.forEach((n,i)=>{
  const w=document.createElement('div');
  w.className='nw';w.id='nw-'+n.id;
  w.innerHTML=`<div class="n-seq">${i+1}</div>
    <div class="nc"><span class="ni">${n.icon}</span><span class="nl">${n.label}</span></div>
    <div class="n-label">${n.sublabel}</div>`;
  w.addEventListener('click',()=>toggle(n.id));
  nodesEl.appendChild(w);
});

let activeId=null;
function toggle(id){
  if(activeId===id){closePanel();return;}
  activeId=id;
  document.querySelectorAll('.nw').forEach(w=>w.classList.toggle('active',w.id==='nw-'+id));
  renderPanel(id);
  document.getElementById('panel').classList.add('open');
  document.getElementById('hint-el').style.display='none';
  document.getElementById('panel-body').style.display='';
}
function closePanel(){
  activeId=null;
  document.querySelectorAll('.nw').forEach(w=>w.classList.remove('active'));
  document.getElementById('panel').classList.remove('open');
  setTimeout(()=>{
    document.getElementById('hint-el').style.display='';
    document.getElementById('panel-body').style.display='none';
  },350);
}

function buildMiniSVG(id){
  const related=getRelated(id);
  const W=160,H=130,cx=54,cy=65,R=22,rR=16;
  const count=related.length;
  const positions=[];
  if(count===1){positions.push({x:130,y:65});}
  else{
    const sa=-70,ea=70;
    for(let i=0;i<count;i++){
      const a=(sa+(ea-sa)*(i/(count-1)))*Math.PI/180;
      positions.push({x:cx+105*Math.cos(a),y:cy+85*Math.sin(a)});
    }
  }
  let s=`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}" viewBox="0 0 ${W} ${H}">`;
  const self=nodes.find(n=>n.id===id);
  related.forEach((r,i)=>{
    const p=positions[i];
    const dx=p.x-cx,dy=p.y-cy,dist=Math.sqrt(dx*dx+dy*dy);
    const x1=cx+dx/dist*R,y1=cy+dy/dist*R,x2=p.x-dx/dist*rR,y2=p.y-dy/dist*rR;
    s+=`<line x1="${x1.toFixed(1)}" y1="${y1.toFixed(1)}" x2="${x2.toFixed(1)}" y2="${y2.toFixed(1)}" stroke="rgba(56,139,212,${(0.2+r.strength*0.6).toFixed(2)})" stroke-width="${(1+r.strength*2.5).toFixed(1)}" stroke-linecap="round"/>`;
  });
  s+=`<circle cx="${cx}" cy="${cy}" r="${R}" fill="var(--color-background-info)" stroke="#378ADD" stroke-width="2"/>`;
  s+=`<text x="${cx}" y="${cy-4}" text-anchor="middle" font-size="13" font-family="var(--font-sans)">${self.icon}</text>`;
  s+=`<text x="${cx}" y="${cy+11}" text-anchor="middle" font-size="8" font-weight="500" font-family="var(--font-sans)" fill="#185FA5">${self.label}</text>`;
  related.forEach((r,i)=>{
    const p=positions[i];
    const other=nodes.find(n=>n.id===r.otherId);
    s+=`<circle cx="${p.x.toFixed(1)}" cy="${p.y.toFixed(1)}" r="${rR}" fill="var(--color-background-primary)" stroke="var(--color-border-secondary)" stroke-width="1.5" style="cursor:pointer" onclick="window._jump('${r.otherId}')"/>`;
    s+=`<text x="${p.x.toFixed(1)}" y="${(p.y-3).toFixed(1)}" text-anchor="middle" font-size="11" font-family="var(--font-sans)" style="pointer-events:none">${other.icon}</text>`;
    s+=`<text x="${p.x.toFixed(1)}" y="${(p.y+9).toFixed(1)}" text-anchor="middle" font-size="7" font-weight="500" font-family="var(--font-sans)" fill="var(--color-text-secondary)" style="pointer-events:none">${other.label}</text>`;
  });
  s+=`</svg>`;
  return s;
}

function renderPanel(id){
  const node=nodes.find(n=>n.id===id);
  const related=getRelated(id);
  const layersHTML=node.layers.map((l,i)=>`
    <div class="ly l${l.lv}" id="ly-${id}-${i}">
      <div class="ly-head" onclick="window._ly('${id}-${i}')">
        <span style="font-size:13px;opacity:.65">${['🌊','🐬','🦑','🌑'][i]}</span>
        <span>${l.label}</span><span class="chev">▶</span>
      </div>
      <div class="ly-body"><ul>${l.items.map(it=>`<li>${it}</li>`).join('')}</ul></div>
    </div>`).join('');
  const relHTML=related.map(r=>{
    const o=nodes.find(n=>n.id===r.otherId);
    return `<div class="rel-row" onclick="window._jump('${r.otherId}')">
      <span class="rel-icon">${o.icon}</span>
      <span class="rel-name">${o.label}</span>
      <span class="rel-label">${r.label}</span>
      <div class="rel-bar-wrap"><div class="rel-bar" style="width:${Math.round(r.strength*100)}%"></div></div>
    </div>`;
  }).join('');
  document.getElementById('panel-body').innerHTML=`
    <div class="panel-header">
      <span class="ph-icon">${node.icon}</span>
      <span class="ph-title">${node.label} · ${node.sublabel}</span>
      <span class="ph-tag">${node.tag}</span>
      <span class="ph-close" onclick="window._close()">✕</span>
    </div>
    <div class="layers-section">${layersHTML}</div>
    ${related.length?`<div class="rel-section">
      <div class="rel-head">知识关联</div>
      <div class="mini-graph-wrap">
        <div>${buildMiniSVG(id)}</div>
        <div class="rel-list">${relHTML}</div>
      </div>
    </div>`:''}`;
}

window._close=closePanel;
window._ly=id=>{document.getElementById('ly-'+id).classList.toggle('open')};
window._jump=id=>{toggle(id);document.getElementById('panel').scrollIntoView({behavior:'smooth',block:'nearest'})};
</script>
```

---

## 生成步骤

1. **理解领域** — 询问用户想覆盖哪个领域，有几个主要节点（建议 4-7 个）
2. **整理数据** — 按节点结构填充 layers，每层 3-5 条；按边结构标注关联强度
3. **适配内容** — 根据领域调整 emoji、标签、层标题措辞
4. **输出组件** — 将数据填入模板，通过 `visualize:show_widget` 工具渲染

## 适配要点

- **节点数量**：4-7 个最佳，超过 7 个圆圈会拥挤
- **层内容**：每层聚焦不同认知角度，不要重复，第 1 层最重要
- **关联强度**：0.9+ 表示「学后者必须先学前者」，0.5 左右表示「有关联但可以独立学」
- **emoji 选择**：优先选能代表该知识性质的符号，不要所有节点都用相似的 emoji
- **中英文**：层标题中文，items 中文为主，专有名词保留英文

## 扩展方向

- **多条主线**：同一知识库可以有多条平行学习路径（如「快速入门路线」vs「完整路线」），在节点上方加 tab 切换
- **进度标记**：节点圆圈可叠加「已完成」状态（实心填充），追踪学习进度
- **难度维度**：节点可附加难度色环，让用户在选择下潜前就能感知复杂度
