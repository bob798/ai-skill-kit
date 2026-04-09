---
name: cc-stats
description: 生成 Claude Code 使用统计报告 — 时间洞察、项目分布、工具画像、生产力趋势。Usage: /cc-stats [--week|--month|--project <name>]
disable-model-invocation: true
allowed-tools: Bash
---

# Claude Code 使用统计

运行 cc-stats CLI 工具，生成终端彩色报告。

## 执行

```bash
cd /Users/bob/workspace/cc-stats && node bin/cli.js $ARGUMENTS
```

将上方命令的完整输出展示给用户，不做任何修改或总结。

## 参数说明

| 参数 | 说明 |
|------|------|
| （空） | 全量报告 |
| `--week` | 本周数据 |
| `--month` | 本月数据 |
| `--from YYYY-MM-DD --to YYYY-MM-DD` | 自定义日期范围 |
| `--project <name>` | 过滤指定项目 |
