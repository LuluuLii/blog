---
date: 2026-01-03
---


需要补的：
1. Execution Engine
	1. flow engine
	2. 长程 agent ？
	3. 真正的 RL 为核心的区别？
2. 如何表达 和执行分支、loop
	1. 不同平台实现和表达 loop 的不同

-----

你已经在做的（前端）是：
- 节点
- 连线
- 参数配置
- 执行状态可视化

你现在需要补的是：  
👉 **这些东西在后端“意味着什么”**
### 1️⃣ 一个工作流 Agent 平台，后端一定在做什么？

无论 Dify / LangGraph / 内部系统，本质上都逃不开这 6 个模块：

`[Workflow DSL]       ↓ [Execution Engine]       ↓ [State Store]       ↓ [Tool Runtime]       ↓ [LLM Gateway]       ↓ [Observability & Eval]`

你要补的不是“代码”，而是**每一层的输入 / 输出是什么**。

---

### 2️⃣ 你需要真正理解的 6 个输入 / 输出（重点）

#### （1）Workflow DSL（定义层）

**输入：**

- 节点类型（LLM / Tool / Condition / Loop）
    
- 边（执行顺序、条件）
    
- 参数绑定（变量名、上下文）
    

**输出：**

- 一份**可执行的结构化定义**（JSON / AST）
    

👉 你要能回答：

- 为什么不用自然语言定义？
    
- DSL 如何支持版本演进？
    

---

#### （2）Execution Engine（执行层）

**输入：**

- Workflow 定义
    
- 初始上下文（input）
    

**输出：**

- 每一步的执行结果
    
- 最终产出
    
- 中间状态（可回放）
    

👉 你要能讲清：

- 串行 vs 并行
    
- Retry / Timeout
    
- 人工介入点（Human-in-the-loop）
    

---

#### （3）State Store（状态层）

**输入：**

- 中间结果
    
- 变量更新
    
- Tool 输出
    

**输出：**

- 当前上下文快照
    
- 历史轨迹（trace）
    

👉 面试高频点：

- 为什么不能只用 prompt context？
    
- 长流程如何防止上下文爆炸？
    

---

#### （4）Tool Runtime（工具层）

**输入：**

- Tool 定义（schema）
    
- Agent 的调用请求
    

**输出：**

- 结构化结果 or 错误
    

👉 你要能讲：

- Tool schema 的设计原则
    
- 同步 / 异步
    
- 错误如何反馈给 Agent
    

---

#### （5）LLM Gateway（模型层）

**输入：**

- Prompt 模板
    
- 上下文
    
- 模型参数
    

**输出：**

- 原始响应
    
- Token / Latency / Cost
    

👉 你要能讲：

- 为什么要有 Gateway
    
- 多模型切换的策略
    

---

#### （6）Observability & Eval（评测层）

**输入：**

- 执行日志
    
- 中间结果
    
- Ground Truth（如果有）
    

**输出：**

- 成功率
    
- 质量评分
    
- 回放能力
    

👉 这是你在 **AI Coding Agent 评测** 中已经接触过的，只是没有系统化。
