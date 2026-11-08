---
date: 2026-02-07
draft: true
---
## 模型能力基础
- LLM
- MLLM
- Grounding 和 Navigation

## GUI 理解

playwright 方案
- [GitHub - microsoft/playwright-mcp: Playwright MCP server](https://github.com/microsoft/playwright-mcp)
browser use
- https://github.com/browser-use/browser-use
- web ui https://github.com/browser-use/web-ui?tab=readme-ov-file 
网页元素 / DOM 树？/结构化信息
截图 --> 多模态模型 GUI grounding + 多模态理解
截图 -->  OCR 
元素 + 截图

后训练模型：
蚂蚁 UI-Venus 强化学习+数据生产管线：数据过滤、重构和生成
- 数据过滤：使用多模态大模型对每个动作进行总结，获得每条轨迹的整体描述
- 数据重构：重构了 UI 导航任务中信息检索类任务的大量轨迹
- 数据生成：整合了自动化框架，基于包含数十台可用手机的虚拟云环境，迭代生成高质量的轨迹
使用规则、结果奖励模型（ORM）和人工三种方式对批量制造的高质量数据进行过滤

#### Grounding 

#### Agent tars
 ---
  Agent TARS 的关键发现

  1. DOM vs VLM vs Hybrid 三种浏览器控制模式

  Agent TARS 经历了从 DOM 到 VLM 再到 Hybrid 的演进，这是一个很有参考价值的实践路径
  模式: DOM
  原理: JS 解析 DOM 提取交互元素编号
  优势: 不需要视觉能力，DeepSeek 等纯文本模型可用
  劣势: LLM 看不到屏幕时操作路径极度复杂，视觉任务直接失败（验证码演示失败）
  ────────────────────────────────────────
  模式: Visual Grounding
  原理: VLM 看截图输出坐标点操作
  优势: 理解视觉布局，框架无关，能处理 Canvas/CSS
  劣势: 需要截图处理时间，实时性较弱
  ────────────────────────────────────────
  模式: Hybrid
  原理: Prompt Engineering 协调两种模式
  优势: 容错更好，DOM 先试 → VLM 兜底
  劣势: 实际性能接近 VLM，增加了复杂度
  对我们的启示：我们的 ui-fast-verify 是状态注入模式（跳过这些问题），但完整框架的
  Executor 模块需要考虑类似策略。

  2. Dropdown 专项处理

  Agent TARS 的 browser-use 包中有专门的 dropdown
  action（https://github.com/bytedance/UI-TARS-desktop）：

  - get_dropdown_options：获取 \<select\> 元素的所有选项
  - select_dropdown_option：按文本匹配选择选项
  - 关键细节：验证元素确实是 HTMLSelectElement、手动 dispatch change/input
  事件、选项未找到时返回可用选项列表

  这说明 dropdown 是一个需要专门处理的交互类型——VLM
  看截图无法看到下拉选项列表（它们是原生渲染的），必须用 DOM 方法。

  3. Context Engineering（非常重要）

  博客最核心的技术洞察之一——长对话 agent 的 context 管理：

  - 20+ 轮交互 × 5000 token 平均工具结果 = 第 26 轮就溢出 128k context
  - 分层记忆：L0 永久（初始输入/最终答案）→ L1 会话级（计划）→ L2
  循环级（工具调用/截图）→ L3 临时（流式数据）
  - 多模态滑动窗口：不同类型内容用不同的窗口策略

  4. Snapshot Framework（可观测性）

  - "Agent UI is just a Replay of Agent Event Stream" —— 所有 agent 行为以事件流表示
  - 快照机制捕获运行时状态，支持确定性重放
  - 帮助他们在 Beta 开发中避免了 10+ 个问题

  5. MCP 不稳定性警告

  - 设计不好的 MCP 一轮调用就可以导致 context 溢出
  - 核心矛盾："Agent 越需要细粒度 Context Engineering 控制，就越不需要 MCP 的静默
  Prompt 注入行为"

  6. UI-TARS 论文的交互验证发现

  - 状态转换描述：训练模型识别连续截图之间的差异，判断操作是否生效
  - 反射学习：agent 学习识别并从自身的错误操作中恢复
  - 小元素感知困难：10×10 像素的图标在 1920×1080 截图中很难精确定位
  - 精细桌面定位只有 <50-60% 绝对性能


