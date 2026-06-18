---
name: ok-itest
description: Generate executable integration-test specs, skeletons, and PR reports for Spring Boot + Spring AI services. Trigger when the user wants to write integration tests, add wire-level ITs, draft an IT spec, or produce a PR test report.
---

# ok-itest — 集成测试生成 skill

> 单文件 skill。面向 **Spring Boot + Spring AI** 后端的集成测试（WireMock stub LLM、Testcontainers 真 DB、多租户隔离）。
> 吸收实战 + TDD skill 的形态约束：anti-pattern 表 + tracer bullet + 短 checklist + 命令式语气。
> 任何细则若与本文件冲突，以本文件为准。**项目内已有规范（CLAUDE.md / 架构文档 / 代码）优先级高于本 skill。**

## 哲学

集成测试 spec 的核心是**可验证契约**，不是描述清楚。

- 一份合格的 IT spec 必须可以被另一个 agent **照着实现并跑通**，无需追加 Q&A。
- 写出来的每一条验收标准都对应一段可执行命令或一个具名 `@Test` method，能输出 PASS/FAIL。
- 报告 = spec 的**回答**；spec 写多少，报告就必须能验证多少。

---

## 反模式（看到这些立刻停手）

| #   | 反模式 | 为什么坏 |
| --- | --- | --- |
| AP1 | 一次写完所有场景的 IT，再统一跑（horizontal slice） | 跑挂时定位成本爆炸；早期决策无证据支撑 |
| AP2 | mock 自己控制的内部 service / repository | 测的是 mock 形状，不是真实行为 |
| AP3 | `@Nested + @SpringBootTest + @TestPropertySource + @DirtiesContext` 组合 | Spring Boot context 缓存语义不可预期，偶发挂 |
| AP4 | WireMock / mock server 用 `localhost` | VPN/特殊网络下 `localhost` 可能被劫持到非 127.x |
| AP5 | Interview 问技术细节（"用 @MockitoBean 还是 BFPP？"） | 这些应由 agent 读代码判断；用户回答没价值 |
| AP6 | spec 字段为了凑齐而填（风险表凑 2 条 / 设计依据预填全部） | 噪音稀释真信号 |
| AP7 | Self-check 用"人工确认 X 已做"代替"运行命令 X 并贴 exit code" | 形式合规，实际没卡住 |

---

## Workflow

四阶段。每阶段都有**可观测交付物**，不是描述。

### 阶段 1 — Explore（先查代码，不要问能查到的）

读下表所有目标后再开口问用户。

| 要找的事实 | 在哪儿 |
| --- | --- |
| 现有 IT base / fakes | `*/support/wiremock/`、`*/test/support/` |
| 同类 IT 骨架（最近 1 份） | `*/integration/*IT.java` |
| 既有 spec / plan / 报告 | `docs/**/itest/`、相邻 spec 目录 |
| 项目领域词汇 | `README.md`、`CLAUDE.md`、相邻 `prd.md` / spec |
| 关键库版本 | `pom.xml` / `build.gradle`（Spring AI、WireMock、JaCoCo 等） |
| 多租户上下文事实 | 项目多租户文档 + `TenantContext` / `JwtAuthenticationFilter` 等鉴权过滤器（**以代码为准**） |

**交付物**：spec 中"复用清单"段已填，每行写明"复用方式（继承 / `@Import` / 直接调用）"。

### 阶段 2 — Locate（路径在写一个字符之前定）

路径**单一语法**（任何 spec 必须严格匹配，否则 self-check 拒绝）：

```
itest-dir = docs/<feature-area>/itest/<NNN-scope>/        # 绑定某 feature
         | docs/tech-specs/<capability>/itest/<NNN-scope>/  # 跨 feature 的能力专项

spec      = <itest-dir>/spec.md
plan      = <itest-dir>/plan.md
reports   = <itest-dir>/reports/
report    = <itest-dir>/reports/pr-<branch-safe>.md
matrix    = <itest-dir>/reports/features.md
scripts   = scripts/itest/<scope>-pr-report.sh                 # repo root，便于 CI
            scripts/itest/<scope>-features-matrix.sh
```

- `NNN`：三位补零，同目录唯一
- `scope`：kebab-case，2-5 词
- `branch-safe = branch.replace('/', '-')`：避免含 `/` 的非法文件名

**历史迁移门禁**：spec.md 落盘前，检查 itest-dir 父链上是否有旧路径的同主题 spec。命中则：

1. **阻断**：不允许新 spec 落新路径，先发 issue 或 commit 把旧资产搬过来；或
2. 在新 spec frontmatter 加 `migrated-from: <旧路径>` 字段记录引用

**交付物**：spec 路径符合上述语法，`reports/` 子目录已建，旧资产关系明确。

### 阶段 3 — Interview（只问业务决策，不问技术细节）

**必问**（每问给推荐答案，一次一个）：

1. 测试入口层：Controller (MockMvc) / Service / Engine / 其他
2. 场景清单：枚举 happy / error / timeout / 边界，每个 = 1 个 `@Test`
3. 非目标（这套 IT **不**回答什么）
4. 回归集（哪些既有 IT 必须不破，给测试类清单或 glob）
5. 稳定性门槛（单次 vs 50×；耗时上限；覆盖率最低线）
6. 是否允许改生产代码

**不要问**（agent 应该读代码判断）：

- bean 替换技术（BFPP vs `@MockitoBean` vs `@ComponentScan(excludeFilters)`）
- WireMock bind 地址、OpenAI base-url 是否加 `/v1`
- JaCoCo 版本
- 上下文 key 列表（看鉴权过滤器 + 生产侧 MDC 调用即可）
- Spring context 策略（先按现有同类 IT 推断，仅在结论会引入风险时确认）
- fixture 策略（先按"最小 stub"默认，仅在涉及外部 schema 合规时确认）

**交付物**：spec 中"Interview 决策"段，6 个必问项各有用户确认的答案。

### 阶段 4 — Tracer Bullet → Incremental Loop

**禁止** horizontal slice（先写完所有 IT 再实现 fakes/stubs/报告链路）。

**Tracer Bullet（第 1 个 PR）必须垂直贯穿**：

```
spec → 1 个 happy-path IT → fakes → stubs → base class → 报告脚本 → coverage
```

跑通后才能进入 incremental loop，每个后续 PR 加 1 个场景。

**交付物**：

- Tracer-bullet PR 在合入前**真跑过一次 PASS**，surefire 摘要贴到 plan
- `<itest-dir>/reports/pr-<branch-safe>.md` 至少存在 1 份
- `features.md` 至少汇总 1 个场景

---

## Spec 模板

**最小必填** + **条件附加**。条件附加段只在触发时出现，未触发就不写。

```markdown
---
name: <scope-slug>
title: <一句话场景目标>
status: DRAFT | REVIEW | STABLE
version: 1.0
last-updated: YYYY-MM-DD
owner: <user>
parents:
  - <相邻 prd.md / tech-spec 路径>
migrated-from: <旧路径>     # 仅当有历史资产时
---

# <一句话场景目标>

## §0 测试原则（把项目既有规范反向继承到本 spec）
<把项目 CLAUDE.md / 架构文档 / 多租户文档里与测试相关的不变量，逐条抄成"规则 + 失败处置"。
 见文末"把仓库规范反向继承到 spec"。>

## 测试目标
<回答什么 / 不回答什么>

## 复用清单
| 类型 | 资产 | 复用方式 |
| ---- | ---- | -------- |

## Interview 决策
| # | 问题 | 答案 |
| - | ---- | ---- |
| 1 | 测试入口层 | <Controller / Service / Engine / 其他> |
| 2 | 是否允许改生产代码 | <是 / 否> |
| 3 | 稳定性门槛 | <单次 / 50×；耗时 ≤Xs；覆盖率 ≥Y%> |
| 4 | 回归集 | <既有 IT 清单 / glob> |
| 5 | 非目标 | <列表> |

## 场景清单
| ID   | 场景 | 触发 | 预期 wire / 状态 | 关联 AC | Test class.method |
| ---- | ---- | ---- | ---------------- | ------- | ----------------- |
| S-01 | …    | …    | …                | AC1     | `FooIT.bar_baz`   |

## 验收标准（AC 表必须可执行）
| AC | 描述（假设…当…则…） | 验证方式 |
| -- | ------------------- | -------- |
| AC1 | 假设…，当…，则…    | `./mvnw verify -Dtest=FooIT#bar_baz` 且输出含 `<token>` |
| AC2 | 假设…，当…，则…    | `FooIT.qux` + `wm.verify(1, postRequestedFor(…))` |

## 外部依赖处理
| 依赖 | 处理方式 | 落地点 | 命中的条件规则 |
| ---- | -------- | ------ | -------------- |

## 上下文准备
| 上下文 | 注入点 | 并发传播 |
| ------ | ------ | -------- |
| MDC.tenant/user/requestId/roles | `@BeforeEach` | … |
| TenantContext | `@BeforeEach` | 仅同线程 |

## 文件级改动清单（只列新增 / 修改，不列"不动"）
| 路径 | 动作 | 说明 |
| ---- | ---- | ---- |

## 报告产物
- PR 报告：`./reports/pr-<branch-safe>.md`（脚本：`scripts/itest/<scope>-pr-report.sh`）
- Features matrix：`./reports/features.md`
- **PASS 判定 = 本 spec §验收标准全部满足**

## 范围之外
- <明确不做的事>：<原因>

## ---- 以下段落条件出现 ----

### Coverage（仅 Interview §稳定性门槛要覆盖率时）
- 工具：JaCoCo `<version>`
- 输出：`target/site/jacoco/jacoco.xml`
- 报告渲染：报告脚本读取并展示 §Coverage 段

### 风险表（仅有真实风险时；不要凑数）
| 风险 | 触发条件 | 应对 |
| ---- | -------- | ---- |

### Bean 替换策略（仅需替换被 @ComponentScan 扫到的真实 bean 时）
| 真实 bean | 替换方式 | 验证断言 |
| --------- | -------- | -------- |

### Fixture / Stub / Matcher（仅 fixture 非平凡时）
- JSON 模板位置 / matcher 策略 / stub 工厂

### 设计依据（仅触发"条件规则"表中任意一条时，逐条写一段）
针对**命中的**条件规则，每条解释为什么这么做、考虑过的其他方案、为何放弃。**未触发的不写**。
```

---

## 条件规则（按触发命中，写进 spec 对应段）

每条 = 触发条件 → 强约束 → 在 spec 哪一段体现 → GOOD/BAD 对照。

### CR1 — `@SpringBootTest` IT 全场景

**强约束**：禁用 `@Nested` 内嵌测试类，IT 必须是顶层类。
**落地段**：spec frontmatter `status` + 文件级改动清单。

### CR2 — 使用 WireMock

**强约束**：`bindAddress("127.0.0.1")`；Spring 属性必须用 `http://127.0.0.1:<port>`。
**落地段**：外部依赖处理 + 设计依据。

```java
// GOOD
WireMockExtension wm = WireMockExtension.newInstance()
    .options(wireMockConfig().bindAddress("127.0.0.1").dynamicPort())
    .build();
r.add("spring.ai.openai.base-url", () -> "http://127.0.0.1:" + wm.getPort());

// BAD —— VPN/特殊网络下 localhost 可能解析到非 127.0.0.1
.options(wireMockConfig().dynamicPort())     // 默认 bind 0.0.0.0 / 走 localhost
r.add("spring.ai.openai.base-url", wm::baseUrl);   // baseUrl() 永远返回 localhost
```

### CR3 — Spring AI OpenAI (≥ 2.0-M4)

**强约束**：`base-url` 末尾**不补** `/v1`（`OpenAiApi.Builder` 默认带）。
**落地段**：外部依赖处理。

```yaml
# GOOD
spring.ai.openai.base-url: http://127.0.0.1:12345

# BAD —— 实际请求会变成 /v1/v1/chat/completions
spring.ai.openai.base-url: http://127.0.0.1:12345/v1
```

### CR4 — 经过 `ParallelToolCallingManager` / 自定义线程池 / 异步

**强约束**：MDC 必须显式 put 租户/用户/请求上下文 key，不能只靠 `TenantContext` ThreadLocal。
**落地段**：上下文准备。

> **MDC key 名以项目代码为准**（常见坑：业务编码 key 如 `tenantCode` 与历史 UUID key 如 `tenantId` 混用）。
> 落 spec 前先 grep 生产侧 `MDC.put(...)` 与鉴权过滤器，确认真实 key 名，**不要照搬本 skill 的示例字面量**。

```java
// GOOD（在 @BeforeEach；key 名替换为项目真实值）
MDC.put("tenantCode", "it-02-tenant");
MDC.put("userId", "it-02-user");
MDC.put("requestId", "it-02-" + UUID.randomUUID());
TenantContext.set("it-02-tenant");

// BAD —— Parallel/异步 worker 只快照 MDC，不传 ThreadLocal
TenantContext.set("it-02-tenant");   // fan-out worker 拿不到 → dispatcher 报 FORBIDDEN(missing_tenant)
```

### CR5 — 需替换已被 `@ComponentScan` 扫到的真实 bean

**强约束**：必须 `BeanFactoryPostProcessor.removeBeanDefinition` + 测试 Fake。
**落地段**：Bean 替换策略。

```java
// GOOD
@Bean
static BeanFactoryPostProcessor removeRealTools() {
    return bf -> {
        if (bf instanceof BeanDefinitionRegistry r) {
            removeBeanDefinitionsForType(bf, r, DeviceStatusTool.class);
        }
    };
}

// BAD —— excludeFilters 对已扫到的 bean 无效；启动直接 "Tool already registered"
@ComponentScan(excludeFilters = @Filter(type = ASSIGNABLE_TYPE, classes = DeviceStatusTool.class))
```

### CR6 — 测试 bean 与生产同名

**强约束**：测试 bean 必须独立命名 + `@Primary`，否则同名 override 顺序不稳。
**落地段**：Bean 替换策略。

```java
// GOOD
@Bean(name = "it_testRetryTemplate")
@Primary
public RetryTemplate retryTemplate() { return RetryTemplate.builder().maxAttempts(1).build(); }

// BAD —— prod 同名 bean 可能反向覆盖测试 bean
@Bean
@Primary
public RetryTemplate retryTemplate() { ... }
```

### CR7 — 报告要 Coverage 且 Java ≥ 21

**强约束**：JaCoCo ≥ 0.8.14（0.8.12 无法 instrument Java 21+ 字节码）。
**落地段**：Coverage（仅条件出现时）。

---

## Per-IT Checklist（合入前必过）

行为判定，不是字段是否填齐。每条挂一个具体命令或 grep。

```
[ ] tracer-bullet PR 真跑过且 PASS（贴 surefire 摘要到 plan）
[ ] 每个 AC 的"验证方式"字段可独立运行，命令带 exit code
[ ] 每个外部依赖都隔离了：grep 跑 IT 时的 stdout/网络日志，没有真实 endpoint / DB 调用
[ ] 若涉及租户：spec 中有"tenant 隔离"断言（非本租户不可见 / 跨租户报错）
[ ] 命中的条件规则在 spec §设计依据 + 对应段（外部依赖 / 上下文 / Bean 替换）双写
[ ] 没命中的条件规则在 spec 中完全不出现
[ ] 报告脚本一行命令产出 `reports/pr-<branch-safe>.md` + `features.md`，CI 可消费
[ ] CI 命令 1 行能跑完整套：`./mvnw verify -Dtest='<...IT>'`
```

---

## Self-check（Process 承诺覆盖矩阵）

verify 时按矩阵逐行走；任一失败：修正后重跑。每条**只 verify Process 阶段承诺过的事**，不引入新约束。

| Process 承诺 | 验证方式 |
| ------------ | -------- |
| 阶段 1：读现有 base/fakes/同类 IT/spec/构建版本 | spec §复用清单 ≥ 1 行；frontmatter 关键库版本写明 |
| 阶段 2：路径符合单一语法 | `bash` 脚本断言 `itest-dir` 匹配正则；branch-safe 已替换 `/` |
| 阶段 2：旧资产已处理 | 若旧 spec 存在 → 新 spec 含 `migrated-from` 或迁移 issue 链接 |
| 阶段 3：6 个必问项都有用户确认答案 | spec §Interview 决策表无 `<占位>` |
| 阶段 3：没问技术细节 | spec / plan 中搜不到 "@MockitoBean vs BFPP" / "WireMock bind 地址要选哪个" 等问句 |
| 阶段 4：tracer bullet PR 已 PASS | plan 中贴有 surefire `Tests run: X, Failures: 0` 摘要 |
| 阶段 4：报告链路通 | `<itest-dir>/reports/pr-<branch-safe>.md` 与 `features.md` 真实存在 |
| Per-IT checklist 8 条全过 | 见上节 |
| 条件规则：命中即落地，未命中即不出现 | 对每条 CR：`grep` spec 关键词触发 → 必须在指定落地段出现；反之必须不在"设计依据"出现 |

---

## 关键差异（vs 需求类 PRD skill / mattpocock TDD）

- **vs PRD skill**：PRD 偏需求表达，字段可松；ok-itest 是可执行契约，AC 必须有验证命令、场景必须有 test class.method。
- **vs mattpocock TDD**：mattpocock 拆 sibling 文件深挖；本 skill 单文件落地，例子内联，借鉴其 anti-pattern + tracer bullet + 短 checklist + 命令式语气。

---

## 把仓库规范反向继承到 spec（每个项目自填）

本 skill 不绑定任何具体仓库。落地到某项目时，**先读该项目的 CLAUDE.md / 架构文档 / 多租户文档 / 后端规范**，把与测试相关的不变量抽成"规则 + 失败处置"，写进每个 spec 顶部的 **§0 测试原则**。每条带源头链接，self-check 拒绝缺失项。

**方法**：每行 = `源头文档 §章节` → `抽取的规则` → `在 spec 哪段落地`。常见可继承项：

- 多租户不变量（业务表租户列非空、租户编码不可变、跨租户隔离断言）→ Per-IT checklist 第 4 条
- 领域词汇约束（实体命名、术语）→ 测试命名 / 注释规范
- 上下文 key 事实（MDC key 名、`TenantContext` 持值类型）→ CR4 强约束
- 基础设施约束（Redis 必须走封装 Key/Service、禁裸 `RedisTemplate`；JWT 走 `JwtService` 等）→ §外部依赖处理"处理方式"
- 异常分层（业务错 vs 服务错用不同 exception）→ 断言对应 exception 类型
- DB 迁移纪律（DDL 必须走 Flyway/迁移脚本，禁手改 schema）→ §文件级改动清单显式列迁移脚本

> **示例**（某 Spring AI 多租户后端的 §0 形态，供参考，落地时换成你项目的真实文档与规则）：
>
> | 源头 | 抽取规则 | 落地方式 |
> |------|----------|---------|
> | `CONTEXT.md` 不可妥协的不变量 | 业务表 `tenant_code TEXT NOT NULL`；编码不可变；FK 用 code | checklist 强制 tenant 断言；fixture 不改 code |
> | 多租户文档 | MDC key 是 `tenantCode`（非 `tenantId`）；`TenantContext` 持 String code | CR4 强约束；fake `@BeforeEach` 必填 |
> | 后端规范 | Redis 必须 `RedisService`/`CacheService` + `RedisKey`，禁裸 `RedisTemplate` | §外部依赖"处理方式"复用封装；测试同禁裸 template |
> | 后端规范 | 业务错 `BusinessException`（warn）/ 服务错 `ServiceException`（error） | 断言对应 exception 类型 |
> | 后端规范 Flyway | DDL/DML 走 Flyway，禁手改 schema | 涉 schema 变更则 §文件级改动清单列迁移脚本 |
>
> **冲突优先级**：项目内规范文档 > 本 skill。**代码与文档冲突时，以代码与迁移脚本为事实。**
