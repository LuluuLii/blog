---
date: 2025-09-07
---


RAG 方案 embedding、Elasticsearch、text2SQL+DB

Claude Code中，记忆是通过当前目录中存储的文件实现的，并且使用grep、rg、awk等传统文本工具进行文本检索。当然实际还需要用户进行一些目录内容的规划，构建一些中间层的表达，方便Agent进行模糊检索。

claude code 逆向
- [GitHub - shareAI-lab/analysis\_claude\_code](https://github.com/shareAI-lab/analysis_claude_code)
- [GitHub - Yuyz0112/claude-code-reverse: A Tool to Visualize Claude Code's LLM Interactions](https://github.com/Yuyz0112/claude-code-reverse)

gemini-cli 

SWE-bench 检索
- 稀疏检索 -- BM25
- oracle 检索
