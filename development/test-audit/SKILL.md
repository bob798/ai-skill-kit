---
name: test-audit
description: Audit test coverage across all dimensions, identify gaps, and generate missing tests with a structured multi-phase approach
argument-hint: "[scope: all | unit | api | component | security | integration | e2e]"
level: 2
---

<Purpose>
对项目测试进行全维度审计，识别覆盖缺口，按优先级生成缺失测试。遵循「先审计→再规划→后执行」的流程，确保测试质量和覆盖率。
</Purpose>

<Use_When>
- 用户说"测试覆盖度"、"自查测试"、"补齐测试"、"test coverage"、"audit tests"
- 项目测试覆盖不完整，需要系统性补齐
- 新功能开发完成后需要验证测试是否充分
- Code review 发现测试缺失
</Use_When>

<Hard_Rules>
- 先审计再写代码，不要直接开始写测试
- 每个测试文件必须独立可运行
- Mock 所有外部依赖，不依赖真实数据库/网络
- React StrictMode 下组件会双渲染：始终用 `getAllBy*` 而非 `getBy*`
- fetch mock 用 `mockImplementation`（每次返回新 Response），不用 `mockResolvedValue`（Response body 只能消费一次）
</Hard_Rules>

## 测试维度矩阵

每次审计必须覆盖以下 6 个维度：

### 1. 单元测试 (Unit)
**目标**: 纯函数、工具函数、常量验证
**典型覆盖**: pricing 计算、rate-limit 逻辑、数据格式化、配置常量
**优先级**: 高（投入低、覆盖快）

### 2. API 路由测试 (API)
**目标**: Next.js route handler 的请求/响应逻辑
**典型覆盖**: 认证检查(401)、输入验证(400)、限流(429)、业务逻辑(402/200)、错误处理(500)
**优先级**: 最高（直接验证核心业务逻辑）
**关键模式**:
```ts
// 创建测试请求
const req = new NextRequest("http://localhost/api/xxx", {
  method: "POST",
  body: JSON.stringify({ ... }),
  headers: { "content-type": "application/json" },
});
// 调用 handler
const res = await POST(req);
expect(res.status).toBe(200);
```

### 3. 组件测试 (Component)
**目标**: UI 渲染、按钮交互、表单提交、状态切换
**典型覆盖**: 页面元素存在性、按钮禁用/启用、表单校验、API 调用触发
**优先级**: 高
**关键模式**:
```tsx
// StrictMode 安全选择器
const btns = screen.getAllByRole("button", { name: /创作/ });
expect(btns.length).toBeGreaterThanOrEqual(1);

// fetch mock（每次返回新 Response）
vi.spyOn(globalThis, "fetch").mockImplementation(
  () => Promise.resolve(new Response(JSON.stringify({ data: "ok" }), { status: 200 }))
);
```

### 4. 安全测试 (Security)
**目标**: 输入清理、XSS 防护、边界值、权限验证
**典型覆盖**: HTML 标签清理、超长输入、特殊字符、未认证访问
**优先级**: 高

### 5. 集成测试 (Integration)
**目标**: 多模块协作的业务流程（mock 数据库层）
**典型覆盖**: 余额扣费→退款链路、注册→赠送余额、支付幂等性
**优先级**: 中
**关键模式**:
```ts
// Mock Prisma $transaction
vi.mock("@/lib/db", () => ({
  prisma: {
    $transaction: vi.fn(async (fn) => fn(mockTx)),
    user: { findUnique: vi.fn(), create: vi.fn() },
  },
}));
```

### 6. E2E 测试 (End-to-End)
**目标**: 浏览器级别的用户完整操作流程
**工具**: Playwright / Cypress
**典型覆盖**: 注册→登录→充值→创作→查看作品
**优先级**: 低（需要运行环境，维护成本高）

## 审计流程

### Phase 1: 扫描现状
```
1. 列出所有源文件 (src/**/*.{ts,tsx})
2. 列出所有测试文件 (src/**/*.test.{ts,tsx})
3. 按维度分类现有测试
4. 生成覆盖矩阵表格
```

### Phase 2: 识别缺口
```
对照 6 个维度，标记每个源文件的测试状态:
- ✅ 已覆盖
- ⚠️ 部分覆盖（缺少关键场景）
- ❌ 未覆盖
```

### Phase 3: 优先级排序
```
按以下顺序补齐:
1. API 路由测试（业务核心）
2. 安全测试（防护底线）
3. 组件测试（用户交互）
4. 单元测试（工具函数）
5. 集成测试（业务流程）
6. E2E 测试（可选）
```

### Phase 4: 并行生成
```
- 不同维度的测试文件无依赖关系，可用 Agent 并行生成
- 每个 agent 负责一个维度
- 生成后统一运行 `npm test` 验证
```

### Phase 5: 验证 & 修复
```
- 运行全部测试
- 修复失败测试（常见: StrictMode 双渲染、Response body 复用、异步时序）
- 确认 0 failure 后提交
```

## 常见陷阱与解法

| 陷阱 | 现象 | 解法 |
|------|------|------|
| React StrictMode 双渲染 | `getByText` 报 "Found multiple elements" | 用 `getAllByText()[0]` |
| Response body 只能读一次 | 第二次 fetch 调用报 body already consumed | `mockImplementation(() => new Response(...))` |
| 异步状态更新 | 断言时组件还没更新 | `await vi.waitFor(() => expect(...))` |
| next/navigation 未 mock | useRouter/usePathname 报错 | `vi.mock("next/navigation", ...)` |
| Prisma 在 jsdom 中不可用 | Module not found: node:module | 完全 mock `@/lib/db` |
| next-auth session | getServerSession 返回 undefined | `vi.mock("next-auth", ...)` |

## 输出格式

审计完成后输出:

```markdown
## 测试审计报告

| 维度 | 文件数 | 测试数 | 覆盖源文件 | 状态 |
|------|--------|--------|-----------|------|
| 单元测试 | N | N | file1, file2 | ✅ |
| API 测试 | N | N | route1, route2 | ✅ |
| 组件测试 | N | N | page1, page2 | ⚠️ 缺 pageX |
| 安全测试 | N | N | - | ✅ |
| 集成测试 | N | N | - | ❌ |
| E2E 测试 | 0 | 0 | - | ❌ 未设置 |

总计: N 个测试文件, N 个测试用例
```
