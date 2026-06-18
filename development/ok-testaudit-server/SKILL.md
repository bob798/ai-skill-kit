---
name: ok-testaudit-server
description: Audit test coverage for the Spring Boot + Spring AI backend (os-server), identify gaps (esp. multi-tenant isolation & LLM tool chains), and generate missing tests with a structured multi-phase approach
argument-hint: "[scope: all | unit | controller | mapper | security | integration | llm]"
level: 2
---

<Purpose>
对 os-server（Java 25 + Spring Boot + Spring AI）后端做全维度测试审计，识别覆盖缺口，按优先级补齐。
遵循「先审计→再规划→后执行」。本 skill 已对齐项目真实惯例（见 `src/test/java`，171 测试文件 / 794 @Test），
非前端/Next 模板。前端是 `os-web`(Nuxt)，与本 skill 无关。
</Purpose>

<Use_When>
- 用户说"测试覆盖度"、"自查测试"、"补齐测试"、"test coverage"、"audit tests"
- 新增 Service/Controller/Mapper/Tool 后需验证测试是否充分
- 多租户/权限/LLM 工具链改动后需确认隔离与边界被覆盖
- Code review 发现测试缺失
</Use_When>

<Stack_Facts>
- 语言/框架：**Java 25 + Spring Boot**；Spring AI(OpenAI model)、MyBatis-Plus、Spring Security + JWT、Redis、AspectJ、WebMVC
- 构建/运行：Maven（`./mvnw test`）；单测与 IT 同跑（项目未分 surefire/failsafe，靠命名 + Docker 可用性区分）
- 测试栈：**JUnit Jupiter** + **Mockito**(`@ExtendWith(MockitoExtension.class)`) + **AssertJ** + `reactor-test`
- 集成：**Testcontainers**(timescale/timescaledb:2.26.2-pg18) + **WireMock**(stub OpenAI / LLM 工具)
- 命名铁律：**`*Test.java` = 快单测（纯 Mockito，无容器）**；**`*IT.java` = 集成（@SpringBootTest + Testcontainers/WireMock，需 Docker）**
- 多租户：`TenantContext`；跨租户/跨用户隔离是一等公民（CrossUserIsolationIT、ScriptCrossTenantIT、ConversationStoreMultiTenantIT…）
- 包根：`cn.com.sigia.pivot.*`；测试镜像源码包结构
</Stack_Facts>

<Hard_Rules>
- 先审计再写代码，不要直接开始写测试
- 命名分级：纯逻辑/mock 协作 → `XxxTest`（Mockito，秒级）；要真 DB/真 LLM/全上下文 → `XxxIT`（@SpringBootTest）。**不要把需要容器的测试命名成 `*Test`**
- 单测一律 `@ExtendWith(MockitoExtension.class)` + `@Mock` 依赖 + `@InjectMocks` 被测类；断言用 **AssertJ**（`assertThat` / `assertThatThrownBy`），不用 JUnit 原生 assert
- Mapper/SQL 测试必须走 **Testcontainers 真 PG**（验证自定义 SQL、JSONB、uuidv7、索引），不要用 H2 假装
- LLM/AI 链路集成用 **WireMock stub OpenAI**（复用 `ai/support/wiremock` 下的 AbstractWireMockScenarioIT / OpenAiRequestMatchers / Fake*Tool），不要打真模型
- **多租户**：任何按 tenant/user 过滤的数据路径，必须有「正向命中 + 跨租户/跨用户拿不到」成对断言；新增 Mapper/Service 默认补隔离用例
- Testcontainers 用**单例容器**模式（静态块 start 一次跨子类共享，进程退出回收），并把 jdbcUrl 的 `localhost` 换 `127.0.0.1`（colima/QEMU IPv6 规避，见 AbstractConversationMapperIT）
- 无 Docker 环境 `*IT` 会失败——审计报告须标注哪些缺口需 Docker 才能补
</Hard_Rules>

## 测试维度矩阵

每次审计覆盖以下 7 个维度（已按本项目重映射）：

### 1. 单元测试 — Service / 工具 (Unit)
**目标**: Service 业务分支、纯逻辑、参数→Mapper 透传、异常路径（`BusinessException` / `ResultCode`）
**典型覆盖**: `ProductServiceTest`、`PermissionServiceTest`、`AuthServiceTest`
**优先级**: 高
**关键模式**:
```java
@ExtendWith(MockitoExtension.class)
class ProductServiceTest {
    @Mock IotProductMapper productMapper;
    @InjectMocks ProductService service;

    @Test
    void listPage_passesDtoToMapperAndReturnsPageVO() {
        when(productMapper.selectPage(any(), any())).thenReturn(new Page<>(1, 15));
        var vo = service.listPage(dto);
        assertThat(vo.getPageNo()).isEqualTo(1);
        verify(productMapper).selectPage(any(), any());
    }

    @Test
    void create_duplicateCode_throwsBusinessException() {
        assertThatThrownBy(() -> service.create(req))
            .isInstanceOf(BusinessException.class);
    }
}
```

### 2. Controller / Web 层 (Controller)
**目标**: 入参绑定、委派 Service、`Result`/`PageVO` 包装、状态码/权限注解
**典型覆盖**: `ProductControllerTest`（Mockito 直测 controller，项目主流）；需要真过滤链时用 `@WebMvcTest` + MockMvc
**优先级**: 最高（核心业务入口）
**关键模式**:
```java
@ExtendWith(MockitoExtension.class)
class ProductControllerTest {
    @Mock ProductService service;
    @InjectMocks ProductController controller;
    @Test void list_delegatesAndWraps() {
        when(service.listPage(dto)).thenReturn(page);
        Result<PageVO<ProductVO>> r = controller.list(dto);
        assertThat(r.getData().getItems()).hasSize(1);
    }
}
```

### 3. 持久层 / Mapper (Mapper)  ⬅ Testcontainers
**目标**: 自定义 SQL、动态条件、JSONB、uuidv7、索引、分页正确性
**典型覆盖**: `AiConversationMapperTest`、`AbstractConversationMapperIT`（共享单例 PG）
**位置/命名**: 真 DB → `*IT` 或基于 Abstract*MapperIT
**优先级**: 高
**关键点**: 单例容器；`127.0.0.1` jdbcUrl；`stringtype=unspecified`；DDL 一次性 `SCHEMA_READY` 守卫

### 4. 安全 / 多租户隔离 (Security)  ⬅ 后端头等维度
**目标**: JWT 校验、权限点、**跨租户/跨用户数据隔离**、未授权 401/403
**典型覆盖**: `JwtAuthenticationFilterTest`、`*PermissionTest`、`CrossUserIsolationIT`、`ConversationStoreMultiTenantIT`、`ScriptCrossTenantIT`
**优先级**: 最高
**审计要点**: 每个带 tenant/user 维度的查询，是否有「A 租户写 → B 租户读不到」的成对断言；沙箱脚本是否验证跨租户泄漏（cross-tenant-leak fixture）

### 5. 集成测试 (Integration)  ⬅ `*IT`
**目标**: 多组件 + 真 DB 的业务链路（会话创建/续写、短事务原子性、重启后持久化、设备/跨设备续连）
**典型覆盖**: `Conversation*IT`、`ShortTransactionIT`、`ChatShortTxAtomicityIT`、`TaskContinuityIT`
**工具**: `@SpringBootTest` + Testcontainers
**优先级**: 中高

### 6. LLM / AI 引擎 (LLM)  ⬅ WireMock
**目标**: ReAct 循环、工具调用（单/串/并行）、流式输出、token 统计、计时、MDC 追踪、超时隔离
**典型覆盖**: `ReActEngine*Test`、`*ToolTest`、`ai/integration/llmtool/*WireIT`（WireMock stub OpenAI）、`TimeoutIsolationIT`
**工具**: WireMock（复用 `OpenAiRequestMatchers` / `Fake*Tool` / `AbstractWireMockScenarioIT`）；流式断言配 `reactor-test`
**优先级**: 高（项目核心能力）

### 7. 沙箱 / 脚本执行 (Sandbox)
**目标**: Docker 沙箱跑用户脚本的安全边界：panic / OOM / 死循环 / 超时 / 跨租户泄漏
**典型覆盖**: `DockerCliTest`、`MultiTenantIsolationIT`、`ScriptCrossTenantIT`，fixture 在 `test/resources/scripts-fixture/*`
**优先级**: 高（安全相关）

## 审计流程

### Phase 1: 扫描现状
```
1. 列出源文件: src/main/java/**/*.java（按 controller/service/mapper/ai/auth/iot 分包）
2. 列出测试: src/test/java/**/*Test.java（快）与 **/*IT.java（重），分别统计
3. 按 7 维度归类现有测试
4. 生成覆盖矩阵
```

### Phase 2: 识别缺口
```
对每个源类标记: ✅ 已覆盖 / ⚠️ 部分（缺异常分支或隔离用例）/ ❌ 未覆盖
重点扫: 新 Service 有无单测; 新 Mapper 有无 Testcontainers IT;
        带 tenant/user 的路径有无跨租户隔离断言; 新 Tool 有无 WireMock 用例
```

### Phase 3: 优先级排序
```
1. 安全 / 多租户隔离（底线）
2. Controller / Service（业务核心）
3. LLM / AI 引擎 + 沙箱（核心能力 + 安全）
4. Mapper（数据正确性，需 Docker）
5. 集成 IT（链路）
6. 纯工具单测
```

### Phase 4: 并行生成
```
- 不同类/不同维度无依赖，可用 Agent 并行生成
- 快单测(*Test)与需 Docker 的 IT 分开排（IT 受容器并发限制）
- 复用既有基类: Abstract*MapperIT / AbstractWireMockScenarioIT / Fake*Tool
- 生成后 ./mvnw test 验证
```

### Phase 5: 验证 & 修复
```
- ./mvnw test（无 Docker 时 *IT 会失败 —— 报告须区分「逻辑缺口」与「需 Docker 环境」）
- 常见失败: 容器未就绪 / IPv6 jdbcUrl / Mockito unnecessary-stubbing(lenient) / 跨租户上下文未清理(@AfterEach TenantContext.clear)
- 全绿后提交
```

## 常见陷阱与解法

| 陷阱 | 现象 | 解法 |
|------|------|------|
| 命名错位 | 需容器的测试叫 `*Test`，CI 无 Docker 时挂 | 重 IT 一律 `*IT` 命名 |
| Testcontainers per-class 抖动 | 第二个测试类拿不到连接 | 单例容器（静态块 start，不 stop） |
| IPv6 握手 EOF | colima/QEMU 下 PG 连接 EOF | jdbcUrl `localhost`→`127.0.0.1` |
| 跨租户上下文残留 | 用例间 TenantContext 串味 | `@AfterEach` 清 `TenantContext` |
| Mockito unnecessary stubbing | strict 模式报 stubbing 未用 | 精确 stub，或局部 `lenient()` |
| H2 假装 PG | 自定义 SQL/JSONB/uuidv7 行为不符 | 用 Testcontainers 真 pg18 |
| 打真 OpenAI | LLM 测试慢/不稳/花钱 | WireMock stub（复用 ai/support/wiremock） |
| 流式断言时序 | Flux 还没发完就断言 | `reactor-test` StepVerifier |

## 输出格式

```markdown
## 测试审计报告 (os-server · Spring Boot)

| 维度 | Test | IT | 覆盖源 | 状态 |
|------|------|----|--------|------|
| Service 单测       | N | - | ProductService… | ✅ |
| Controller         | N | - | ProductController| ⚠️ 缺 XxxController |
| Mapper (容器)      | - | N | Conversation*    | ✅ |
| 安全/多租户隔离    | N | N | CrossUser*       | ⚠️ 缺 XxxMapper 隔离 |
| 集成 IT            | - | N | Conversation*IT  | ✅ |
| LLM/AI 引擎        | N | N | ReActEngine*     | ✅ |
| 沙箱/脚本          | N | N | Script*          | ⚠️ |

总计: N 个 *Test, N 个 *IT, N 个 @Test 方法
缺口（标注是否需 Docker）与建议补齐顺序: 1) … 2) …
```
