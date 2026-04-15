---
name: vector-db-guide
description: >
  向量数据库选型、使用与调优 Skill。当用户提到"向量数据库怎么选"、"Chroma 和 Milvus 有什么区别"、"embedding 怎么存"、"相似度搜索怎么做"、"向量检索太慢"、"RAG 用哪个向量库"时触发。适用于 RAG 系统搭建、向量数据库选型、面试向量数据库考题。
---

# Vector DB Guide Skill

你是一位熟悉主流向量数据库的 AI 工程师。你的任务是：**帮助用户理解向量数据库的核心原理，做出合理的选型决策，解决使用中的具体问题**——不只是介绍产品，而是给出"什么场景用什么，为什么"的工程判断。

---

## 核心概念

```
向量数据库解决什么问题？

传统数据库：精确匹配（WHERE name = 'xxx'）
向量数据库：语义相似（找和这段文字"意思最像"的内容）

工作原理：
原始文本/图片
    │
    ▼
Embedding 模型（text-embedding-3-small / BGE / bge-m3）
    │
    ▼
向量（1536 维的浮点数数组）[0.12, -0.34, 0.89, ...]
    │
    ▼
向量数据库（存储 + 索引）
    │
    ▼
相似度搜索（余弦相似度 / 点积 / 欧氏距离）
    │
    ▼
返回最相似的 Top-K 结果
```

---

## 主流向量数据库对比

### 快速选型表

| 数据库 | 定位 | 最适合场景 | 不适合 |
|--------|------|-----------|--------|
| **Chroma** | 本地开发首选 | 原型验证、本地 RAG、学习用途 | 生产大规模 |
| **Milvus** | 开源生产级 | 自建生产环境、大规模数据（亿级）| 快速原型 |
| **Qdrant** | 性能 + 易用 | 中等规模生产、需要精细过滤 | 超大规模 |
| **Pinecone** | 全托管 SaaS | 快速上线、不想维护基础设施 | 成本敏感、数据私有化 |
| **pgvector** | PostgreSQL 插件 | 已有 PG 基础设施、数据量 < 百万 | 超大规模向量检索 |
| **Weaviate** | 多模态 | 图文混合检索、GraphQL 接口 | 纯文本简单场景 |
| **FAISS** | 纯检索库 | 研究/离线批处理、不需要持久化 | 生产在线服务 |

---

## 各库深度说明

### Chroma — 开发阶段必备

```python
import chromadb

client = chromadb.Client()  # 内存模式，进程结束数据消失
# 或
client = chromadb.PersistentClient(path="./chroma_db")  # 持久化到本地

collection = client.create_collection("docs")

# 存入文档（Chroma 内置 embedding，也可以自己传向量）
collection.add(
    documents=["文档内容1", "文档内容2"],
    ids=["doc1", "doc2"],
    metadatas=[{"source": "pdf", "page": 1}, {"source": "web"}]
)

# 查询
results = collection.query(
    query_texts=["用户的问题"],
    n_results=3,
    where={"source": "pdf"}  # 元数据过滤
)
```

**优势**：零配置，Python 原生，Langchain/LlamaIndex 深度集成
**劣势**：不适合并发，数据量 > 100 万开始变慢，无分布式支持

---

### Milvus — 生产环境标准选择

```python
from pymilvus import connections, Collection, FieldSchema, CollectionSchema, DataType, utility

# 连接
connections.connect("default", host="localhost", port="19530")

# 定义 Schema
fields = [
    FieldSchema(name="id", dtype=DataType.INT64, is_primary=True, auto_id=True),
    FieldSchema(name="embedding", dtype=DataType.FLOAT_VECTOR, dim=1536),
    FieldSchema(name="text", dtype=DataType.VARCHAR, max_length=65535),
    FieldSchema(name="source", dtype=DataType.VARCHAR, max_length=256),
]
schema = CollectionSchema(fields)
collection = Collection("docs", schema)

# 创建索引（影响检索速度和精度的关键配置）
index_params = {
    "metric_type": "COSINE",   # 余弦相似度（文本推荐）
    "index_type": "HNSW",      # 常用索引类型
    "params": {"M": 16, "efConstruction": 200}
}
collection.create_index("embedding", index_params)
collection.load()  # 加载到内存才能查询

# 插入
collection.insert([[embedding_list], [text_list], [source_list]])

# 查询
results = collection.search(
    data=[query_embedding],
    anns_field="embedding",
    param={"metric_type": "COSINE", "ef": 100},
    limit=5,
    expr='source == "manual"',  # 标量过滤
    output_fields=["text", "source"]
)
```

**关键概念**：
- **索引类型**：HNSW（高精度）、IVF_FLAT（大数据量）、IVF_SQ8（节省内存）
- **metric_type**：COSINE（文本）、IP（内积，归一化后同 COSINE）、L2（图像）
- **Milvus Lite**：单机轻量版，开发测试用，不需要 Docker

---

### pgvector — 最低运维成本方案

```sql
-- 安装扩展
CREATE EXTENSION IF NOT EXISTS vector;

-- 建表
CREATE TABLE documents (
    id SERIAL PRIMARY KEY,
    content TEXT,
    embedding vector(1536),
    source VARCHAR(256),
    created_at TIMESTAMP DEFAULT NOW()
);

-- 创建索引
CREATE INDEX ON documents USING ivfflat (embedding vector_cosine_ops)
WITH (lists = 100);  -- lists = sqrt(数据量)

-- 查询（找最相似的 5 条）
SELECT content, source,
       1 - (embedding <=> '[0.1, 0.2, ...]'::vector) AS similarity
FROM documents
WHERE source = 'manual'
ORDER BY embedding <=> '[0.1, 0.2, ...]'::vector
LIMIT 5;
```

**适用场景**：已有 PostgreSQL + 数据量 < 百万 + 团队不想多维护一套中间件

---

## Embedding 模型选型

| 模型 | 维度 | 适用 | 成本 |
|------|------|------|------|
| `text-embedding-3-small` | 1536 | 英文为主，性价比高 | $0.02/1M tokens |
| `text-embedding-3-large` | 3072 | 高精度需求 | $0.13/1M tokens |
| `bge-m3` | 1024 | 中英文双语，开源免费 | 自部署 |
| `bge-large-zh-v1.5` | 1024 | 中文专用，效果好 | 自部署 |
| `nomic-embed-text` | 768 | 开源，Ollama 本地运行 | 免费 |

**中文 RAG 推荐**：`bge-m3`（中英文混合效果最好）

---

## 常见问题与优化

### 检索慢
```
数据量 < 10 万：不需要索引优化，通常是代码问题
数据量 10万~1000万：HNSW 索引，调大 ef 参数
数据量 > 1000万：考虑分片（Milvus）或换更适合的索引类型
```

### 相似度分数怎么设阈值
```python
# 余弦相似度范围 0~1（归一化后），经验值：
# > 0.85：高度相关
# 0.70~0.85：相关
# < 0.70：弱相关，通常不应返回给 LLM

results = collection.query(
    ...,
    where={"$and": [{"score": {"$gt": 0.70}}]}  # Chroma 示例
)
```

### 元数据过滤设计原则
```
只把"需要过滤"的字段放元数据，不要把所有内容都塞进去：

✅ 应该放：source（来源）、doc_type（文档类型）、created_at（时间）、department（部门）
❌ 不要放：完整文章内容、大文本字段（影响过滤性能）
```

---

## 面试高频问题速答

**Q：Chroma 和 Milvus 怎么选？**
> 原型/开发用 Chroma，生产超百万数据用 Milvus。团队有 PostgreSQL 且数据量不大，用 pgvector 最省事。

**Q：相似度搜索用哪种距离？**
> 文本用余弦相似度（COSINE），它对向量长度不敏感，适合长度不一的文档。

**Q：向量数据库和传统数据库有什么区别？**
> 传统数据库做精确匹配，向量数据库做近似最近邻搜索（ANN）。两者通常配合使用：向量库找相似，传统库做精确过滤。

**Q：HNSW 是什么？**
> Hierarchical Navigable Small World，一种图结构的 ANN 索引算法。构建时慢，查询时快，内存占用较高。是目前精度和速度平衡最好的索引类型。
