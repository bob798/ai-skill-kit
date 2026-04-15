---
name: langchain-patterns
description: >
  LangChain 核心模式与实战 Skill。当用户提到"LangChain 怎么用"、"LCEL 是什么"、"LangChain 的 Chain 怎么写"、"LangChain Memory"、"LangChain Agent"、"LangChain 和直接调 API 有什么区别"、"LangChain 太复杂怎么办"时触发。适用于 LangChain 入门、核心概念理解、面试 LangChain 考题、决策是否引入 LangChain。
---

# LangChain Patterns Skill

你是一位熟悉 LangChain 生态的 AI 工程师，同时了解它的适用边界和常见吐槽。你的任务是：**帮助用户掌握 LangChain 的核心使用模式，做出是否引入 LangChain 的合理决策，解答面试中的 LangChain 相关问题**。

---

## 先想清楚：需不需要 LangChain？

```
LangChain 的价值：
✅ 标准化了 LLM 调用、Memory、工具调用等的接口
✅ 大量预置组件（文档加载器、向量库集成、Agent 工具）
✅ LangSmith 提供链路追踪和调试
✅ 生态成熟，社区大

LangChain 的代价：
⚠️ 抽象层多，出问题时调试困难（"黑盒感"）
⚠️ 版本迭代快，旧代码容易失效
⚠️ 简单任务引入后代码反而更复杂
⚠️ LCEL 语法需要额外学习成本

判断原则：
- 需要快速集成多种文档源/向量库/工具 → 用 LangChain
- 需要 RAG、Agent 等标准场景 → 用 LangChain（节省大量代码）
- 只是调用 LLM API 做生成 → 直接用 Anthropic/OpenAI SDK 更简单
- 需要高度定制化的流程控制 → 考虑直接写，或用 LangGraph
```

---

## 核心概念地图

```
LangChain 核心抽象

├── Model（模型层）
│   ├── LLM（文本输入输出）
│   └── ChatModel（消息输入输出）← 现在主流
│
├── Prompt（提示层）
│   ├── PromptTemplate
│   ├── ChatPromptTemplate
│   └── MessagesPlaceholder（插入历史消息）
│
├── Chain（链）
│   ├── LCEL（LangChain Expression Language）← 新版推荐
│   └── 各种预置 Chain（RetrievalQA / ConversationalRetrievalChain 等）
│
├── Memory（记忆）
│   ├── ConversationBufferMemory（完整历史）
│   ├── ConversationBufferWindowMemory（滑动窗口）
│   └── ConversationSummaryMemory（摘要压缩）
│
├── Retriever（检索）
│   ├── VectorStoreRetriever（向量检索）
│   └── MultiQueryRetriever / ContextualCompressionRetriever（高级）
│
└── Agent（智能体）
    ├── ReAct Agent
    ├── OpenAI Functions Agent
    └── LangGraph（复杂多步骤/多 Agent 场景）
```

---

## 核心模式 1：LCEL（现代 LangChain 的基础）

LCEL（LangChain Expression Language）用管道符 `|` 把组件串起来：

```python
from langchain_anthropic import ChatAnthropic
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser

# 模型初始化
llm = ChatAnthropic(model="claude-sonnet-4-6")

# Prompt 模板
prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个{role}，用中文回答问题。"),
    ("human", "{question}")
])

# 输出解析器
parser = StrOutputParser()

# 用 | 组合成 Chain（LCEL 核心语法）
chain = prompt | llm | parser

# 调用
result = chain.invoke({
    "role": "技术专家",
    "question": "什么是 RAG？"
})

# 流式输出
for chunk in chain.stream({"role": "技术专家", "question": "什么是 RAG？"}):
    print(chunk, end="", flush=True)

# 批量处理
results = chain.batch([
    {"role": "专家", "question": "问题1"},
    {"role": "专家", "question": "问题2"},
])
```

---

## 核心模式 2：RAG Chain

```python
from langchain_community.vectorstores import Chroma
from langchain_openai import OpenAIEmbeddings
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.runnables import RunnablePassthrough

# 1. 构建向量库
vectorstore = Chroma(
    persist_directory="./chroma_db",
    embedding_function=OpenAIEmbeddings()
)
retriever = vectorstore.as_retriever(
    search_type="similarity",
    search_kwargs={"k": 4}  # Top-4 检索
)

# 2. RAG Prompt 模板
rag_prompt = ChatPromptTemplate.from_template("""
基于以下上下文回答问题。如果上下文中没有相关信息，直接说"我没有找到相关信息"。

上下文：
{context}

问题：{question}
""")

def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

# 3. 组合 RAG Chain（LCEL 写法）
rag_chain = (
    {"context": retriever | format_docs, "question": RunnablePassthrough()}
    | rag_prompt
    | llm
    | StrOutputParser()
)

answer = rag_chain.invoke("什么是向量数据库？")
```

---

## 核心模式 3：带记忆的对话

```python
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.messages import HumanMessage, AIMessage

# 带历史消息的 Prompt
prompt = ChatPromptTemplate.from_messages([
    ("system", "你是一个 AI 助手，记住之前的对话内容。"),
    MessagesPlaceholder(variable_name="history"),  # 插入历史
    ("human", "{input}")
])

chain = prompt | llm | StrOutputParser()

# 手动管理历史（比 LangChain Memory 更可控）
history = []

def chat(user_input: str) -> str:
    response = chain.invoke({
        "history": history,
        "input": user_input
    })
    # 更新历史
    history.append(HumanMessage(content=user_input))
    history.append(AIMessage(content=response))
    # 控制历史长度（最多保留 10 轮）
    if len(history) > 20:
        history[:] = history[-20:]
    return response
```

---

## 核心模式 4：带工具的 Agent

```python
from langchain_core.tools import tool
from langchain.agents import create_react_agent, AgentExecutor
from langchain import hub

# 定义工具
@tool
def search_docs(query: str) -> str:
    """在产品文档中搜索相关内容。输入搜索关键词，返回相关文档片段。"""
    results = vectorstore.similarity_search(query, k=3)
    return "\n".join([doc.page_content for doc in results])

@tool
def calculate(expression: str) -> str:
    """执行数学计算。输入数学表达式，返回计算结果。"""
    try:
        return str(eval(expression))
    except:
        return "计算失败，请检查表达式格式"

tools = [search_docs, calculate]

# 使用 LangChain Hub 的 ReAct Prompt
prompt = hub.pull("hwchase17/react")

agent = create_react_agent(llm, tools, prompt)
agent_executor = AgentExecutor(
    agent=agent,
    tools=tools,
    max_iterations=5,      # 防止死循环
    verbose=True,          # 打印每步思考过程，调试用
    handle_parsing_errors=True  # 输出格式错误时自动重试
)

result = agent_executor.invoke({"input": "帮我查找关于退款政策的文档"})
```

---

## 文档加载与分割（RAG 预处理）

```python
from langchain_community.document_loaders import PyPDFLoader, DirectoryLoader
from langchain.text_splitter import RecursiveCharacterTextSplitter

# 加载文档
loader = PyPDFLoader("document.pdf")
# 或批量加载目录
loader = DirectoryLoader("./docs", glob="**/*.pdf", loader_cls=PyPDFLoader)
docs = loader.load()

# 分割文档（关键参数）
splitter = RecursiveCharacterTextSplitter(
    chunk_size=512,       # 每块大小（tokens 近似）
    chunk_overlap=64,     # 重叠大小（保证上下文连续性）
    separators=["\n\n", "\n", "。", "！", "？", " ", ""]  # 中文优先按段落分
)
chunks = splitter.split_documents(docs)

# 入库
vectorstore = Chroma.from_documents(
    documents=chunks,
    embedding=OpenAIEmbeddings(),
    persist_directory="./chroma_db"
)
```

---

## 面试高频问题速答

**Q：LangChain 和直接调用 LLM API 有什么区别？**
> LangChain 提供了标准化的抽象层：统一接口调用不同 LLM、预置 RAG/Agent 组件、链路追踪。代价是引入额外复杂度。简单场景直接用 SDK，复杂场景用 LangChain 节省代码量。

**Q：LCEL 是什么，为什么要用？**
> LangChain Expression Language，用 `|` 管道符组合组件。优势是声明式语法、天然支持流式/批量/异步，方便链路追踪。替代了旧版的 `LLMChain`。

**Q：LangChain Memory 怎么选？**
> 短对话用 `ConversationBufferWindowMemory`（只保留最近 N 轮）。长对话用 `ConversationSummaryMemory`（LLM 压缩旧历史）。生产环境建议自己管理历史列表，更可控。

**Q：LangChain 和 LangGraph 什么关系？**
> LangGraph 是 LangChain 团队出的有状态图执行引擎，适合复杂多步骤、有条件分支、多 Agent 协作场景。简单链式流程用 LCEL，复杂工作流用 LangGraph。
