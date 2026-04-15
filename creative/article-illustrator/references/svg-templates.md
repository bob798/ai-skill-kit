# SVG 模板库 · SVG Templates

六种图片类型的标准代码模板。复制后替换内容变量即可使用。

---

## 通用常量（所有模板共用）

```javascript
const O  = '#F26419', O3 = '#FDF4EE';  // 品牌橙
const BK = '#1C1C1C', G1 = '#3A3A3A';  // 深色文字
const G2 = '#7A7A7A', G3 = '#BEBEBE';  // 灰色
const G4 = '#E8E8E8', WH = '#FAF9F6';  // 背景
const W  = '#FFFFFF';                   // 纯白

const t = (x, y, s, sz, c, a='start', w='normal') =>
  `<text x="${x}" y="${y}" text-anchor="${a}" font-family="'PingFang SC',Georgia,sans-serif" font-size="${sz}" fill="${c}" font-weight="${w}">${s}</text>`;

const rule = (x, y, w, c=G4, h=1) =>
  `<rect x="${x}" y="${y}" width="${w}" height="${h}" fill="${c}"/>`;

const brand = `<rect x="40" y="40" width="36" height="4" fill="${O}"/>
  <rect x="40" y="40" width="4" height="36" fill="${O}"/>`;
```

---

## 类型1：封面图 Cover

```javascript
const W_ = 750, H_ = 1050;
// 替换变量：
const SERIES = 'AI 团队管理系列';
const TITLE  = '管AI团队\n你管的不是人';
const TITLE2 = '是上下文';
const SUB    = '协作语言变了，你准备好了吗？';
const NUM    = '01';  // 文章编号，留空则不显示

const body = `
  <rect width="${W_}" height="${H_}" fill="${WH}"/>
  ${brand}
  <!-- 品牌橙侧栏 -->
  <rect x="${W_-80}" y="0" width="80" height="${H_}" fill="${O}" opacity="0.08"/>
  <rect x="${W_-12}" y="0" width="12" height="${H_}" fill="${O}"/>
  <!-- 编号 -->
  ${NUM ? `<text x="60" y="200" font-family="Georgia,serif" font-size="120" fill="${O}" opacity="0.08" font-weight="bold">${NUM}</text>` : ''}
  <!-- 主标题 -->
  ${t(60, 320, TITLE.split('\n')[0], 52, BK, 'start', 'bold')}
  ${t(60, 388, TITLE.split('\n')[1] || '', 52, BK, 'start', 'bold')}
  ${t(60, 444, TITLE2, 52, O, 'start', 'bold')}
  <!-- 分割线 -->
  <rect x="60" y="474" width="120" height="3" fill="${O}"/>
  <!-- 副标题 -->
  ${t(60, 516, SUB, 20, G2)}
  <!-- 系列标记 -->
  ${t(60, H_-48, SERIES, 13, G2)}
`;
```

---

## 类型2：对比图 Comparison

```javascript
const W_ = 750, H_ = 900;
// 替换变量：
const TITLE = '协作语言的转变';
const LEFT_LABEL = '旧协作语言';
const RIGHT_LABEL = 'AI 协作语言';
const LEFT_ITEMS  = ['靠默契和常识', '研发会提出异议', '碰撞激活隐性知识', '认知负担分布'];
const RIGHT_ITEMS = ['靠显性上下文', 'AI 只执行不挑战', '激活机制消失', '认知负担前置'];

const body = `
  <rect width="${W_}" height="${H_}" fill="${WH}"/>
  ${brand}
  ${t(60, 100, TITLE, 28, BK, 'start', 'bold')}
  ${rule(60, 118, 630, G3, 2)}

  <!-- 左侧（旧） -->
  <rect x="40" y="140" width="310" height="${H_-200}" rx="10" fill="${W}" stroke="${G4}" stroke-width="1.5"/>
  ${t(195, 182, LEFT_LABEL, 16, G2, 'middle', 'bold')}
  ${rule(60, 196, 270, G4)}
  ${LEFT_ITEMS.map((item, i) => `
    <rect x="56" y="${218 + i*64}" width="6" height="6" rx="3" fill="${G3}"/>
    ${t(72, ${228 + i*64}, item, 15, G1)}
  `).join('')}

  <!-- 右侧（新） -->
  <rect x="400" y="140" width="310" height="${H_-200}" rx="10" fill="${BK}" stroke="${BK}" stroke-width="0"/>
  ${t(555, 182, RIGHT_LABEL, 16, O, 'middle', 'bold')}
  <rect x="410" y="196" width="290" height="1" fill="${G2}"/>
  ${RIGHT_ITEMS.map((item, i) => `
    <rect x="416" y="${218 + i*64}" width="6" height="6" rx="3" fill="${O}"/>
    ${t(432, ${228 + i*64}, item, 15, W)}
  `).join('')}

  <!-- 中间 VS -->
  <circle cx="375" cy="${H_/2}" r="28" fill="${WH}" stroke="${G4}" stroke-width="1.5"/>
  ${t(375, ${H_/2 + 7}, 'VS', 14, G2, 'middle', 'bold')}
`;
```

---

## 类型3：流程图 Flow

```javascript
const W_ = 750, H_ = 1050;
// 替换变量：
const TITLE = '重建激活机制：三个动作';
const STEPS = [
  { num: '01', title: '假设清单', desc: '开工前把所有「我以为」写出来' },
  { num: '02', title: '自我评审', desc: '扮演研发角色，追问自己三个问题' },
  { num: '03', title: '结构化验收', desc: '提前定标准，不事后凭感觉' },
];

const body = `
  <rect width="${W_}" height="${H_}" fill="${WH}"/>
  ${brand}
  ${t(60, 110, TITLE, 26, BK, 'start', 'bold')}
  ${rule(60, 128, 630, G3, 2)}

  ${STEPS.map((step, i) => {
    const y = 160 + i * 260;
    const isLast = i === STEPS.length - 1;
    return `
    <!-- Step ${step.num} -->
    <rect x="40" y="${y}" width="670" height="220" rx="12"
      fill="${i % 2 === 0 ? W : BK}" stroke="${i % 2 === 0 ? G4 : BK}" stroke-width="1.5"/>
    <rect x="40" y="${y}" width="6" height="220" fill="${O}" rx="3"/>
    <text x="80" y="${y+56}" font-family="Georgia,serif" font-size="44"
      fill="${i % 2 === 0 ? O : O}" font-weight="bold" opacity="0.6">${step.num}</text>
    ${t(154, y+46, step.title, 26, i%2===0?BK:W, 'start', 'bold')}
    ${t(80, y+100, step.desc, 16, i%2===0?G2:G3)}
    ${!isLast ? `
    <line x1="375" y1="${y+220}" x2="375" y2="${y+248}" stroke="${G3}" stroke-width="2"/>
    <polygon points="370,${y+244} 375,${y+256} 380,${y+244}" fill="${G3}"/>` : ''}
    `;
  }).join('')}
`;
```

---

## 类型5：金句卡片 Quote

```javascript
const W_ = 750, H_ = 750;
// 替换变量：
const QUOTE = 'AI 不会偷懒\n但会非常认真地做错事';
const SOURCE = '——《重新发明协作》系列';

const lines = QUOTE.split('\n');
const body = `
  <rect width="${W_}" height="${H_}" fill="${WH}"/>
  ${brand}

  <!-- 大引号装饰 -->
  <text x="52" y="280" font-family="Georgia,serif" font-size="200"
    fill="${O}" opacity="0.06" font-weight="bold">"</text>

  <!-- 金句 -->
  ${lines.map((line, i) =>
    t(375, 340 + i*72, line, 36, BK, 'middle', 'bold')
  ).join('')}

  <!-- 分割线 -->
  <rect x="300" y="${340 + lines.length*72 + 24}" width="150" height="2" fill="${O}"/>

  <!-- 来源 -->
  ${t(375, ${340 + lines.length*72 + 60}, SOURCE, 15, G2, 'middle')}
`;
```

---

## 类型6：知识地图 Map

见系列规划图的完整代码，结构较复杂，建议从已有输出文件中复制调整。

---

## 多图颜色域分配（系列配图）

当一个系列有多个知识领域时，用颜色区分：

```javascript
const DOMAINS = {
  '知识管理学': { fill: '#1A5276', light: '#D6EAF8' },
  '软件工程':   { fill: '#1E8449', light: '#D5F5E3' },
  'AI 对齐':    { fill: '#7D3C98', light: '#F4ECF7' },
  '认知科学':   { fill: '#B7770D', light: '#FDEBD0' },
  'Context工程':{ fill: '#1A6B7A', light: '#D1F2EB' },
};
```