---
name: ok-testaudit-nuxt
description: Audit test coverage for the Nuxt 3 + Vitest + Playwright frontend (os-web), identify gaps, and generate missing tests with a structured multi-phase approach
argument-hint: "[scope: all | unit | component | integration | security | e2e]"
level: 2
---

<Purpose>
对 os-web（Nuxt 3 + Vue 3）前端做全维度测试审计，识别覆盖缺口，按优先级生成缺失测试。
遵循「先审计→再规划→后执行」的流程。本 skill 已对齐项目真实测试惯例（见 `test/unit`、`test/nuxt`、`test/e2e`），
非 React/Next 通用模板。后端是 `os-server`(Spring AI/Java)，前端**没有 API 路由**，不要按 Next route handler 思路写测试。
</Purpose>

<Use_When>
- 用户说"测试覆盖度"、"自查测试"、"补齐测试"、"test coverage"、"audit tests"
- 前端测试覆盖不完整，需要系统性补齐
- 新功能（composable / 组件 / store）开发完成后需要验证测试是否充分
- Code review 发现测试缺失
</Use_When>

<Stack_Facts>
- 测试框架：**Vitest**，配两个 project（`vitest.config.ts`）：
  - `unit` → `environment: 'node'`，匹配 `test/unit/*.spec.ts`（纯逻辑、composable、store、类型）
  - `nuxt` → `environment: 'nuxt'` + happy-dom（@nuxt/test-utils），匹配 `test/nuxt/*.spec.ts`（组件渲染/交互）
- 组件挂载：`mountSuspended` from `@nuxt/test-utils/runtime`（**不是** @testing-library/react）
- E2E：**Playwright**（`@nuxt/test-utils/playwright`），`test/e2e/*.spec.ts`，webServer 跑 `pnpm run dev`
- 源码别名：`#layers/base/app/...`（Nuxt Layers）；测试文件统一 `.spec.ts` 后缀
- 状态：**Pinia**；DOM 环境是 **happy-dom**
- 运行命令：`pnpm test` / `pnpm test:unit` / `pnpm test:nuxt` / `pnpm test:e2e`
</Stack_Facts>

<Hard_Rules>
- 先审计再写代码，不要直接开始写测试
- 测试文件按环境放对目录：node 逻辑 → `test/unit/`，需要渲染 DOM/Nuxt 上下文 → `test/nuxt/`
- 组件测试一律用 `await mountSuspended(Comp, { props })`，查询用 `wrapper.find()/findAll()/text()`
- Mock 所有外部依赖（网络、后端 API），不依赖真实后端/网络
- **Vue 没有 React StrictMode 双渲染**——正常用 `find`/`findAll`，不需要 `getAllBy*` 兜底
- node-env 单测里 Nuxt 自动导入不存在：用 `vi.stubGlobal` 注入 `ref/computed/useCookie/useRuntimeConfig` 等，或 `vi.mock` 掉 composable
- nuxt-env 组件测试改 Nuxt 自动导入用 `mockNuxtImport('useXxx', () => () => ({...}))`（**不是** `vi.mock`）
- mock 函数若要在被 hoist 的 `vi.mock` 工厂里引用，必须用 `vi.hoisted()` 提升，保持 import-under-test 在首位（满足 import/first）
- 异步渲染/状态：用 `await flushPromises()`（from `@vue/test-utils`）或 `await nextTick()` 后再断言
</Hard_Rules>

## 测试维度矩阵

每次审计覆盖以下 6 个维度（已按本项目重映射）：

### 1. 单元测试 — 纯逻辑 (Unit)
**目标**: 纯函数、列表过滤/排序逻辑、类型守卫、数据映射
**典型覆盖**: `iot-product-list-logic`、`iot-product-types`、表单校验 `app-create-form-validation`
**位置**: `test/unit/*.spec.ts`（node env）
**优先级**: 高（投入低、覆盖快）

### 2. API 客户端 / Composable 测试 (API-Client)
**目标**: `use*Api` composable 的请求 URL、入参、响应映射（后端 VO → 前端 model）
**典型覆盖**: `useChatApi`、`use-*-api` 系列、auth 权限计算
**优先级**: 最高（这是前端业务核心，替代了 Next 的 route handler 维度）
**关键模式**:
```ts
import { describe, expect, it, vi, beforeEach } from 'vitest'
import { useChatApi } from '#layers/base/app/composables/useChatApi'

// 用 vi.hoisted 提升 mock，保证可在 hoisted 的 vi.mock 工厂中引用
const requestMock = vi.hoisted(() => vi.fn())
vi.mock('#layers/base/app/composables/useApi', () => ({
  useApi: () => ({ request: requestMock }),
}))
vi.stubGlobal('useApi', () => ({ request: requestMock }))

describe('useChatApi', () => {
  beforeEach(() => vi.clearAllMocks())
  it('listConversations 默认走 GET /ai/conversations?limit=20', async () => {
    requestMock.mockResolvedValue([])
    await useChatApi().listConversations()
    expect(requestMock).toHaveBeenCalledWith('/ai/conversations?limit=20')
  })
  it('映射后端 VO → 前端 model（updateTime→updatedAt，丢弃 status）', async () => {
    requestMock.mockResolvedValue([{ id: 'c1', status: 'x', updateTime: 't' }])
    const list = await useChatApi().listConversations()
    expect(list[0]).toEqual({ id: 'c1', title: undefined, updatedAt: 't' })
  })
})
```

### 3. 组件测试 (Component)
**目标**: 组件渲染、props 驱动、按钮禁用/启用、表单校验、事件触发
**典型覆盖**: `LoginScreen`、`MessageBubble`、`ToolCallCard`、`ConversationSidebar`、`AppWindow`
**位置**: `test/nuxt/*.spec.ts`（nuxt env）
**优先级**: 高
**关键模式**:
```ts
import { mountSuspended, mockNuxtImport } from '@nuxt/test-utils/runtime'
import { describe, expect, it } from 'vitest'
import LoginScreen from '#layers/base/app/components/LoginScreen.vue'

// 替换 Nuxt 自动导入（auto-import）——用 mockNuxtImport，不是 vi.mock
mockNuxtImport('useToast', () => () => ({ add: vi.fn() }))

describe('LoginScreen', () => {
  it('字段为空时登录按钮禁用', async () => {
    const wrapper = await mountSuspended(LoginScreen)
    expect(wrapper.find('button[type="submit"]').attributes('disabled')).toBeDefined()
  })
  it('按文案找按钮（happy-dom，无双渲染）', async () => {
    const wrapper = await mountSuspended(LoginScreen)
    const sms = wrapper.findAll('button').find((b) => b.text().includes('获取验证码'))
    expect(sms).toBeDefined()
  })
})
```

### 4. 安全测试 (Security)
**目标**: 输入清理、XSS 防护、Markdown/HTML 渲染转义、边界值、未授权访问的 UI 行为
**典型覆盖**: `MarkdownRender` 对恶意 HTML 的转义、超长输入、特殊字符、权限缺失时的可见性
**优先级**: 高（注意：前端只承担「前端防护」，鉴权底线在后端 `os-server`）

### 5. 集成测试 (Integration)
**目标**: 多模块协作的真实链路，只在**网络边界** mock（真实 composable + 真实子组件 + mock fetch/SSE）
**典型覆盖**: `ai-chat-stream-integration`（真实 `useChatStream` SSE 字节解析 → 逐字渲染 → ToolCard → done/error）
**位置**: `test/nuxt/*.spec.ts`
**优先级**: 中
**关键模式**:
```ts
import { mockNuxtImport, mountSuspended } from '@nuxt/test-utils/runtime'
import { flushPromises } from '@vue/test-utils'
import { ref } from 'vue'

mockNuxtImport('useChatApi', () => () => ({
  listConversations: vi.fn(async () => []),
  getMessages: vi.fn(async () => []),
}))
// 真实子组件 + 真实流解析；只 mock 掉网络边界的 fetch，返回真实 SSE 字节流
// ... 构造 sseFrame('token', seq, data)，stub fetch，driver 后 await flushPromises()
```
Pinia 链路：node 单测用 `setActivePinia(createPinia())`；nuxt 组件测试可用 `@pinia/testing` 的 `createTestingPinia`。

### 6. E2E 测试 (End-to-End)
**目标**: 浏览器级真实流程（接真实/stub 后端）
**工具**: **Playwright**（`test/e2e/*.spec.ts`，`pnpm test:e2e`）
**典型覆盖**: `login`（发送验证码→登录→进桌面）、`ai-chat`、`platform-admin`
**优先级**: 低（需 dev server + 后端，维护成本高）
**关键模式**:
```ts
import { expect, test } from '@playwright/test'
test('登录主流程', async ({ page }) => {
  await page.goto('/')
  await page.getByPlaceholder('手机号').fill('13800000000')
  const sms = page.waitForResponse((r) => r.url().includes('/auth/sms-code') && r.request().method() === 'POST')
  await page.getByRole('button', { name: '获取验证码' }).click()
  expect((await sms).status()).toBe(200)
  await expect(page.getByText('PivotOS')).toBeVisible()
})
```

## 审计流程

### Phase 1: 扫描现状
```
1. 列出源文件: app/**/*.{ts,vue}、layers/**/app/**（composables / components / stores / utils）
2. 列出测试文件: test/unit/*.spec.ts、test/nuxt/*.spec.ts、test/e2e/*.spec.ts
3. 按维度分类现有测试（unit/api-client/component/security/integration/e2e）
4. 生成覆盖矩阵表格
```

### Phase 2: 识别缺口
```
对照 6 个维度，标记每个源文件的测试状态:
- ✅ 已覆盖   - ⚠️ 部分覆盖（缺关键场景/分支）   - ❌ 未覆盖
重点查: 每个 use*Api 是否有 URL+映射断言; 每个交互组件是否有渲染+禁用/事件断言
```

### Phase 3: 优先级排序
```
1. API 客户端 / Composable（业务核心）
2. 安全测试（前端防护）
3. 组件测试（用户交互）
4. 单元测试（纯逻辑/工具）
5. 集成测试（端到端管线，mock 网络边界）
6. E2E（可选，需 server）
```

### Phase 4: 并行生成
```
- 不同维度/不同文件无依赖，可用 Agent 并行生成
- 每个 agent 负责一个文件或一个维度
- node 逻辑放 test/unit/，渲染相关放 test/nuxt/
- 生成后统一运行 pnpm test 验证
```

### Phase 5: 验证 & 修复
```
- pnpm test:unit && pnpm test:nuxt（E2E 单独 pnpm test:e2e，需要 dev server）
- 修复失败（常见: 自动导入未 mock、异步未 flushPromises、别名/Pinia 未初始化）
- 0 failure 后提交
```

## 常见陷阱与解法

| 陷阱 | 现象 | 解法 |
|------|------|------|
| Nuxt 自动导入未 mock | `useToast`/`useChatApi` is not defined | 组件测试用 `mockNuxtImport(...)`；node 单测用 `vi.stubGlobal`/`vi.mock` |
| 用错 mock API | `vi.mock` 改不动 auto-import | auto-import 必须 `mockNuxtImport`；普通模块才 `vi.mock` |
| hoist 顺序 | mock fn 在 vi.mock 工厂里 undefined | 用 `const fn = vi.hoisted(() => vi.fn())` |
| 异步状态未更新 | 断言时 DOM 还没变 | `await flushPromises()` 或 `await nextTick()` |
| node 单测缺 Vue/Nuxt 全局 | `ref`/`useCookie` is not defined | `vi.stubGlobal('ref', ref)` 等，或把逻辑测进 test/nuxt |
| Pinia 未初始化 | `getActivePinia()` 报错 | 单测 `setActivePinia(createPinia())`；组件 `createTestingPinia` |
| 放错 project 目录 | 渲染测试在 node env 跑挂 | DOM/组件 → test/nuxt；纯逻辑 → test/unit |
| 误用 Next 思路 | 想 mock NextRequest/Prisma/next-auth | 本项目没有这些；前端无 API 路由，鉴权在后端 |

## 输出格式

审计完成后输出:

```markdown
## 测试审计报告 (os-web · Nuxt)

| 维度 | 文件数 | 用例数 | 覆盖源 | 状态 |
|------|--------|--------|--------|------|
| 单元(纯逻辑)    | N | N | logic1, logic2 | ✅ |
| API 客户端       | N | N | useXxxApi…      | ✅ |
| 组件            | N | N | Comp1, Comp2   | ⚠️ 缺 CompX |
| 安全            | N | N | MarkdownRender | ⚠️ |
| 集成            | N | N | stream-integ   | ✅ |
| E2E (Playwright)| N | N | login, ai-chat | ⚠️ |

总计: N 个测试文件, N 个用例
缺口与建议补齐顺序: 1) … 2) …
```
