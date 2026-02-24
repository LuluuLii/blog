“在做 AI Coding Agent 评测时，发现一次性 Prompt 很难覆盖复杂 UI，于是我把评测拆成 Plan / Act / Observe / Decide 的 Agent Loop，引入 Playwright 作为 Tool，并用多模态模型做视觉判断，同时引入状态存储来支持回放和重试。”

---

## 如何把它升级成真正的 Agent（可操作）

### 1️⃣ 明确你的评测 Agent 的「目标」

先把目标说清楚：

> **给定一个前端工程或页面，自动评测其：
> - UI 是否符合预期
> - 核心功能是否可用**

这已经是一个**明确任务**。

---

### 2️⃣ 最小 Agent 结构（非常重要）

你可以把它拆成一个**简单但真实的 Agent Loop**：

`Goal → Plan → Act → Observe → Decide → (Loop)`

---

### 3️⃣ 每一步你需要的输入 / 输出（落地版）

#### （1）Plan（规划）

**输入：**

- 项目结构 / 页面入口
    
- 测试目标（来自 spec）
    

**输出：**

- 一组测试步骤（页面 → 操作 → 验证点）
    

👉 可由 LLM 生成，但要结构化输出。

---

#### （2）Act（执行）

**输入：**

- 测试步骤
    
- 当前状态
    

**输出：**

- Playwright 执行结果
    
- Screenshot / DOM / Error
    

👉 Playwright = Tool

---

#### （3）Observe（观察）

**输入：**

- 页面截图
    
- DOM
    
- 控制台日志
    

**输出：**

- 模型对 UI / 功能的判断
    
- 局部问题定位
    

👉 多模态模型最有价值的地方。

---

#### （4）Decide（决策）

**输入：**

- 当前评测结果
    
- 是否通过阈值
    

**输出：**

- 是否继续测试
    
- 是否 retry
    
- 是否标记失败
    

👉 这一步**让它成为 Agent**。

---

### 4️⃣ 最低可行的 Agentic 改造路径（2–3 周）

#### Week 1：

- 把 Prompt 输出改成 JSON
    
- 明确 Plan / Act / Observe
    

#### Week 2：

- 加一个简单 Loop（失败 → 重试）
    
- 保存中间状态
    

#### Week 3：

- 加评测汇总
    
- 输出结构化报告

## 一、问题拆解

你目前遇到的问题：

1. **美学识别不稳定**：
    
    - 问题：多模态模型无法准确判断间距、配色对比、元素重叠。
        
    - 目标：用 Agent 来组织多轮判断和规则辅助，增强鲁棒性。
        
2. **截图未加载完成**：
    
    - 问题：异步加载导致截图不完整。
        
    - 目标：Agent 控制截图流程，确保资源加载完成再截图。
        
3. **多张截图需求**：
    
    - 目标：支持按页面区域或状态批量截图，并将结果送入后续 Agent 处理。
        
4. **功能性自动化测试**：
    
    - 目标：Agent 生成并执行 e2e 用例（Playwright / Chrome DevTools MCP），并收集结果。
        

---

## 二、Agent 拆分策略

设计原则：

- **一个 Agent 做一类明确任务**（高 Cohesion）
    
- **多 Agent 协作完成完整流程**（低 Coupling）
    
- **支持状态追踪 / 中间产物存储 / 可重复执行**
    

### 建议的 Agent 模块

|Agent|职责|输入|输出|可实现技术|
|---|---|---|---|---|
|**Task Manager Agent**|总控 Agent，调度所有子 Agent，维护任务状态|用户指定测试页面 URL 或页面列表|每个子任务分配给相应 Agent|Node.js / TypeScript / Workflow 状态存储|
|**Page Loader & Screenshot Agent**|控制页面加载和截图，保证资源加载完成，支持多截图|URL、截图策略|截图文件或 buffer|Playwright / Puppeteer / headless Chrome|
|**Aesthetic Evaluator Agent**|美学评测（多模态 + 规则混合）|截图|评分 / 建议 / JSON 结构化报告|OpenAI Vision / BLIP / Clip / 规则引擎|
|**Functionality Test Generator Agent**|生成 e2e 测试用例（基于页面 + prompt）|页面元素信息 / 测试目标|Playwright 测试脚本 / 测试指令|LLM (Python / JS)|
|**Test Executor Agent**|执行生成的测试脚本并收集结果|测试脚本|测试结果 JSON|Playwright / MCP|
|**Report Aggregator Agent**|汇总所有 Agent 输出，生成统一报告|美学评分 + 功能测试结果|JSON / HTML 报告|Node.js / React 展示|

> 可选：**Feedback Agent**  
> 如果你想做“Agent 自我改进”循环，可增加一个 Feedback Agent，对生成的测试或美学评分进行评估和修正，增强鲁棒性。

---

## 三、流程设计（Agent 协作顺序）

`用户输入 URL / 页面列表           │           ▼ Task Manager Agent           │           ├─> Page Loader & Screenshot Agent → 截图           │           ├─> Aesthetic Evaluator Agent → 美学评分 / 建议           │           ├─> Functionality Test Generator Agent → e2e 测试脚本           │           └─> Test Executor Agent → 测试结果           │           ▼ Report Aggregator Agent → 汇总报告 → 前端展示 / API 输出           │ (Optional) Feedback Agent → 调整 Generator / Evaluator 参数 → 循环优化`

### 核心特点

- **多 Agent 协作**：每个 Agent 职责单一，可独立测试
    
- **中间产物存储**：截图、美学评分、测试脚本、测试结果，都存储到数据库或 S3
    
- **循环优化**：Feedback Agent 可改进 e2e 用例或美学判断参数
    
- **可扩展性**：增加新的评测类型，只需增加 Agent，不影响其他模块
    

---

## 四、架构层次设计

### 1️⃣ 前端展示

- 显示测试页面、截图、评分、测试结果
    
- 可交互（选择截图、触发重新评测）
    

### 2️⃣ 后端 Orchestrator

- Task Manager Agent 核心调度
    
- 状态管理（任务、截图、中间产物）
    
- 可用 Node.js + TypeScript
    
- API Gateway 提供外部接口
    

### 3️⃣ Agent 模块

- 每个 Agent 单独可部署 / 可测试
    
- 使用 **LLM + 规则引擎**混合美学判断
    
- 使用 Playwright / DevTools MCP 执行截图和功能测试
    
- 输出结构化 JSON
    

### 4️⃣ Persistence Layer

- SQLite / Postgres + 文件系统 / S3
    
- 存储任务状态、中间产物、日志
    

---

## 五、工程落地建议

1. **先实现最小流程**：
    
    - Task Manager → Page Loader & Screenshot → Aesthetic Evaluator → Report Aggregator
        
    - 支持单个页面、单张截图、美学评分
        
    - 用简单规则弥补多模态模型识别不足
        
2. **再扩展功能**：
    
    - 多截图支持
        
    - Functionality Test Generator + Test Executor
        
    - Feedback Agent 循环优化
        
3. **美学评分策略**：
    
    - 结合模型输出 + 规则
        
    - 例如：
        
        - 元素重叠检测 → DOM / BoundingBox
            
        - 配色对比 → RGB / LAB 距离
            
        - 间距 → 元素尺寸与栅格对比
            
4. **截图问题解决**：
    
    - Page Loader Agent 等待页面 load event + 指定延迟
        
    - 支持多区域截图
        
    - 可以保存全页面截图 + 局部截图
        

---

## 六、Agent 数量总结

|Agent|必要性|描述|
|---|---|---|
|Task Manager|必须|总控 / 流程调度|
|Page Loader & Screenshot|必须|页面加载和截图|
|Aesthetic Evaluator|必须|美学评分|
|Functionality Test Generator|可选（后期）|生成自动化 e2e 测试|
|Test Executor|可选（后期）|执行 e2e 测试|
|Report Aggregator|必须|汇总输出报告|
|Feedback Agent|可选（后期）|循环优化 Agent 输出|

> 初期最小可交付：**Task Manager + Page Loader & Screenshot + Aesthetic Evaluator + Report Aggregator**  
> 后期可逐步扩展到 Functionality Test + Test Executor + Feedback Agent，实现完整 agentic 测试闭环


# 评测 Agent 系统（整合版）

## 一、系统模块概览（Agent 拆分）

`Task Manager Agent        │        ├─> Page Loader Agent (页面加载、资源稳定)        │        ├─> Planner Agent (生成评测计划：操作/截图序列)        │        ├─> Interaction & Screenshot Agent (核心增强模块)        │       ├─ 执行 Planner 指定操作        │       ├─ 等待页面稳定        │       ├─ 多轮截图/多状态截图        │       └─ 输出截图 + 操作记录        │        ├─> Aesthetic Evaluator Agent (美学评估)        │       ├─ 结合多模态模型 + 规则        │       └─ 输出评分/建议        │        ├─> Functionality Test Generator Agent (可选后期)        │       └─ 自动生成 e2e 测试脚本        │        ├─> Test Executor Agent (可选后期)        │       └─ 执行脚本 + 收集结果        │        └─> Report Aggregator Agent                └─ 汇总截图 + 操作 + 美学/功能评分 → 输出报告`

### 核心设计点

1. **Interaction & Screenshot Agent**是你重点开发模块
    
    - 实现动态交互 + 多状态截图
        
    - 可结合 Planner Agent 生成的操作序列
        
    - 支持操作失败重试和状态回滚
        
    - 输出结构化 JSON：截图 + 操作记录 + 页面状态
        
2. **Planner Agent**负责定义“哪些操作需要交互”
    
    - 点击、滚动、输入等
        
    - 支持单页面或多页面测试任务
        
3. **Aesthetic Evaluator Agent**和**Report Aggregator Agent**保持原有逻辑
    
    - 确保面试展示时，你可以讲“完整 Agent 流程 + 状态管理 + 多轮循环”
        

---

## 二、1 月内可执行计划（4 周）

假设你**在工作时间推进**，每周 5 天，核心目标是完成交互截图模块，并整合进整体评测系统。

### **Week 1：基础架构 + 页面加载**

- 搭建 Node.js 后端框架（Express / Fastify）
    
- Page Loader Agent：
    
    - 页面加载 + 资源稳定等待
        
    - 支持单页面截图测试
        
- Task Manager Agent：
    
    - 调度 Page Loader → 后续 Agent
        
- 输出 Demo：
    
    - 单页面加载 + 基础截图（静态，无交互）
        
- 面试可讲点：
    
    - 后端架构设计
        
    - Agent 拆分逻辑
        

---

### **Week 2：Planner Agent + Interaction 基础**

- Planner Agent：
    
    - 定义操作序列（点击按钮、滚动、hover）
        
    - 输出 JSON 任务计划
        
- Interaction & Screenshot Agent：
    
    - 实现基本操作执行 + 截图
        
    - 支持操作失败重试
        
- 输出 Demo：
    
    - 页面交互后截图
        
    - 保存操作记录
        
- 面试可讲点：
    
    - 多轮 Agent 流程
        
    - 状态管理 + 中间产物
        

---

### **Week 3：多状态截图 + 美学评估接口**

- Interaction & Screenshot Agent：
    
    - 支持多状态截图（多操作、多页面）
        
    - 保存每张截图对应操作和状态
        
- Aesthetic Evaluator Agent：
    
    - 接入多模态模型 + 简单规则
        
    - 输出每张截图评分 / 建议
        
- 输出 Demo：
    
    - 页面多轮操作截图 + 美学评分
        
    - 可展示操作 → 截图 → 评分的闭环
        
- 面试可讲点：
    
    - Agent 协作
        
    - Workflow + 状态追踪
        
    - 模型 + 规则结合的工程思路
        

---

### **Week 4：整合 + 报告 + 面试准备**

- Report Aggregator Agent：
    
    - 汇总 Interaction & Screenshot + Aesthetic Evaluator 输出
        
    - 生成最终 JSON / HTML 报告
        
- 整体流程测试：
    
    - 多页面 + 多操作 + 多截图完整演示
        
- 输出 Demo：
    
    - 可交付的评测系统小 Demo
        
- 面试可讲点：
    
    - 完整 Agent 系统
        
    - 状态管理 + 多轮循环
        
    - 工程可靠性
        
    - 扩展性（功能测试可选后期）

## 模型直接生成单测 vs 模型执行操作序列

1. **Planner Agent**
    
    - 根据页面 URL / 需求生成操作序列
        
    - 可选：同时输出单测脚本模板（方案 B）
        
2. **Interaction & Screenshot Agent / Test Executor Agent**
    
    - 执行 Planner 的操作序列（方案 A）
        
    - 执行模型生成的单测脚本（方案 B）
        
3. **Evaluator Agent**
    
    - 对截图 + 页面状态进行评估
        
    - 对单测执行结果做汇总（通过 / 失败 / 建议）
        
4. **Report Aggregator Agent**
    - 汇总操作序列、截图、测试结果、自动生成单测覆盖率

| 维度                 | 方案 A：模型规划 + Agent 执行交互                   | 方案 B：模型生成单测文件                           |
| ------------------ | ---------------------------------------- | --------------------------------------- |
| **测试覆盖性**          | 依赖模型生成操作序列，覆盖动态交互，可能遗漏某些操作路径或状态          | 依赖模型理解代码 + 需求描述，可以系统生成覆盖用例，覆盖率更可控       |
| **动态页面 / 异步加载适应性** | 强：可等待资源加载、页面交互、截图多状态                     | 弱：生成单测文件通常假设静态 DOM，可结合等待策略，但对复杂异步交互敏感度低 |
| **重复性 / 稳定性**      | 中：每次操作可能受元素定位失败、网络延迟影响                   | 高：生成的单测脚本在相同环境下重复执行结果一致                 |
| **多轮交互能力**         | 强：支持点击、滚动、输入等序列操作，能评估页面变化                | 弱：单测文件多半是静态检查或简单操作，难覆盖复杂多状态流程           |
| **开发复杂度**          | 高：需要 Planner + Interaction + 状态管理 + 异常处理 | 中：生成单测文件 + 执行环境即可                       |
| **准确性（判定功能是否正常）**  | 取决于操作覆盖和截图评估策略，可能漏掉状态                    | 高：单测直接断言代码行为，结果确定性强                     |
| **综合测试精准度**        | 高动态交互场景适用，中间产物可检查，但可能漏路径                 | 高代码逻辑测试 / 自动化断言场景更准，特别是功能验证             |
- **如果页面交互复杂、动态内容多、需要多状态截图和人为感知评估（如 UI/美学/体验）**  
    → **方案 A 更适合**
    - 可捕获动态页面状态变化
    - 可模拟用户操作序列
    - 精准度受 Planner 设计和操作覆盖限制

- **如果主诉求是功能性测试、覆盖逻辑、判断页面功能是否正确**  
    → **方案 B 更适合**
    - 单测文件可精准覆盖业务逻辑和断言
    - 可重复执行，误报率低
    - 稳定性和可维护性高
        
- **实际工程建议**：
    
    - **混合方案最稳妥**
        
        - 对 **功能逻辑和代码行为** → 方案 B（单测文件）
            
        - 对 **用户交互流程和动态页面状态** → 方案 A（Agent 执行交互）
            
    - 结合后，可以实现 **高覆盖 + 高动态适应性** 的测试系统