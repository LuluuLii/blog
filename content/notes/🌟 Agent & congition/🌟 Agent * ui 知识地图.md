---
date: 2026-02-02
---


## 大纲

### Agent Architecture 基础

> 🎯 目标：你能设计 agent 系统。

核心模式：
- ReAct
- Plan-Execute-Reflect
- Hierarchical agent
- Tool-based agent
- Memory systems
- Multi-agent collaboration

### Agent × Browser

> 🎯 目标：让 agent 操作 UI。

关键问题：
- 如何让 agent 理解 UI state？
- 如何规划 UI actions？
- 如何评估 UI result？
- 如何避免 hallucination？

技术：
- DOM / screenshot / accessibility fusion
- UI state abstraction
- Action planning
- Feedback loop

### Agent Evaluation & Testing

> 🎯 目标：你能“评估 agent”。

核心：
- multimodal evaluation
- UI test generation
- self-critique / reflection
- trace-based evaluation
- metric design

## Project
####  UI Understanding Agent / UI graph engine
功能：
- 输入网页 URL
- 输出：
    - UI graph（结构树 节点、层级、空间关系）
    -  semantic labels（button / nav / card）
    - 关键交互点 interaction map
    - 视觉层级 visual hierarchy
    - 美学评分

技术点：
- Playwright + screenshot + CDP
- DOM + Accessibility Tree
- layout info extraction
- LLM reasoning
- UI graph abstraction & modeling
#### UI Testing Agent
功能：
- 自动探索页面（点击 / 跳转 ）
- 多轮交互
-  截图 + DOM + trace
- 功能 & 美学评测
- 输出测试报告

技术点：
- Agent planning
- Playwright tool calling
- Multi-modal evaluation
- Trace analysis

#### Content Agent

把 UI / 数据转成内容。

例如：
- chart → narrative
- UI → explanation
- video → structured summary
- data → story

满足个人兴趣，但必须：UI / Browser / Agent 三者结合。
