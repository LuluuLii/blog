---
date: 2026-02-16
---


### 概念
短期记忆 vs 长期记忆 vs 知识库
- 短期记忆(Short-term Memory, STM)：
	- 会话缓冲（Context）记忆：保留最近对话历史的滚动窗口，确保回答上下文相关性；
	- **工作记忆**：存储当前任务的临时信息，如中间结果、变量值等。
- Memory 目前在产品层 还是一个比较模糊的概念 有的是对事实/信息的记忆、有的是挖掘“用户偏好” 

### 应用层 / 产品层

对话型 agent：Gemini，claude chat，chatgpt ，豆包等智能体的「自动记忆」功能

用户偏好其实是比较难对齐的，实践例子
- [Rethinking Agent的用户偏好挖掘](https://zhuanlan.zhihu.com/p/1988681851137712312)
- 余一的[AI as me](https://zhida.zhihu.com/search?content_id=268296337&content_type=Article&match_order=1&q=AI+as+me&zd_token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJ6aGlkYV9zZXJ2ZXIiLCJleHAiOjE3NzExNjUxNDksInEiOiJBSSBhcyBtZSIsInpoaWRhX3NvdXJjZSI6ImVudGl0eSIsImNvbnRlbnRfaWQiOjI2ODI5NjMzNywiY29udGVudF90eXBlIjoiQXJ0aWNsZSIsIm1hdGNoX29yZGVyIjoxLCJ6ZF90b2tlbiI6bnVsbH0.-Ki1H1NwhWYpLUgMTATq_lgw4lPYGwU_LKUFUL6j7XU&zhida_source=entity)的实践


对不同场景，需要记忆的东西不一样
- 语义记忆： 事实/信息/知识。e.g. 记住用户偏好、产品信息等
	- 档案式语义记忆 user profile
		- 档案通常是一个JSON文档，包含各种键值对来表示用户的不同属性
		- conversation + old profile --LLM--> new profile
	- 集合式语义记忆
		- 创建许多小的记忆卡片，每个卡片记录一个特定的信息点。随着交互的进行，智能体会不断添加新的记忆卡片，形成一个不断增长的记忆集合。
- 情景记忆：经历，e.g. 记录过去的交互历史和行动
	- 记录过去的交互经历和行为。当智能体遇到类似的任务时，它可以回顾过去是如何处理的，从中学习并改进。
	- 少样本学习
- 程序记忆：存储和更新系统指令与提示

几种常见的场景和记忆的不同侧重点（[Agentic AI基础设施实践经验系列（三）：Agent记忆模块的最佳实践 \| 亚马逊AWS官方博客](https://aws.amazon.com/cn/blogs/china/agentic-ai-infrastructure-deep-practice-experience-thinking-series-three-best-practices-for-agent-memory-module/)）：
- 代码助手类智能体：
	- 记忆应侧重用户项目的上下文和偏好。包括：用户项目的项目背景、**代码库结构**（文件组织、模块关系）、**命名风格**（变量命名约定、代码格式风格）、常用的框架库以及用户以前提供的代码片段或指令等。
- 智能客服类智能体：
	- 记忆的重点是**用户历史和偏好**，以便提供连贯且个性化的服务。包括：用户当前任务的状态，提过的问题、故障、产品使用，服务配置，和解决方案记录。当用户第二次来询问类似问题时，不必重复描述自己之前的问题细节，系统能够回忆起**上次给出的建议**或已经尝试过某些步骤，直接切入重点解决当前问题。
	- 此外，记忆用户的产品使用情况和喜好（例如偏好哪种通信渠道，是否倾向自助解决）可以使响应更加贴合用户习惯。这样实现更快的问题解决和更高的客户满意度，增强对品牌的信任。
- 个人助理类智能体：
	- 记忆重点包括：**用户个人信息和日程表**、**目标**（如健身学习计划）、经常执行的**行为模式**（如每周几锻炼）以及对应用和服务的偏好（如偏好哪种提醒方式）等。
	- 这样智能体会提醒日程，并结合过往偏好提供个性化安排（比如知道用户周五喜欢外卖，在傍晚时主动推荐餐厅）。随着交互增加，**持续的长期记忆**使智能体能**不断适应用户**，逐渐减少对用户指令的依赖，实现更**主动**和**贴心**的服务。
- 推荐服务智能体：
	- 记忆重点包括：用户的显式反馈（如用户给某本书点赞或明确表达不喜欢某商品）和隐式反馈（如浏览记录、点击行为、购买历史）
	- 以此构建兴趣档案，在后续交互中个性化推荐，并持续学习，对过往推荐的反馈（是否点击、购买），不断调整推荐策略，更新画像。提高推荐转化率也增强用户忠诚度。


记忆触发时机
- 即时记忆
- 事后记忆
	- 触发时机


百炼 [为智能体应用配置长期记忆存储个性化信息-大模型服务平台百炼-阿里云](https://help.aliyun.com/zh/model-studio/long-term-memory)
- 记忆片段
- 记忆变量
### 技术层

技术演进：长期记忆必须逐步内化为模型能力，而不只是工程外挂
1.  向量数据库或知识库做 RAG，把它当成模型的「外部硬盘」
2. 长期记忆不只是检索答案，而是需要参与推理过程，影响模型的决策和行为。长期记忆不再只是为对话服务，而是直接决定智能体是否具备持续进化能力
3. RL ？Online learning ？

传统技术方案
- 检索增强生成（RAG）
- 全上下文处理

记忆策略
- 通过事件/轮数触发，实现监控逻辑，在对话累积或话题转换时，让大模型对近期对话生成摘要，提取关键信息并添加标签便于检索。
- 支持用户主动标记需要记住的信息
记忆存储
- 记忆数据通常采用用户→会话→记忆片段的三层结构管理。用户层区分不同账号空间，会话层隔离各对话上下文，记忆片段层存储具体内容及元数据（如时间、关键词、来源等）。复杂系统可能需要维护多个记忆库
记忆检索：记忆查询和召回逻辑


记忆维度
- 会话
- 对话
- 用户

如何组织和存储记忆
- json 文档
- 向量数据库
- 文件系统
- 知识图谱

#### 工程
Mem0
- [GitHub - mem0ai/mem0: Universal memory layer for AI Agents](https://github.com/mem0ai/mem0)
- [AI Memory Research: 26% Accuracy Boost for LLMs \| Mem0](https://mem0.ai/research)
- 基础版
	- 提取阶段
		- 输入：最新消息对（用户提问+AI回复）+ 最近10条消息 + 全局对话摘要
		- 处理：通过 GPT-4o-mini 提取候选记忆
	- 更新阶段
	- ![[Pasted image 20260214155128.png]]

AgentScope [长期记忆 - AgentScope](https://doc.agentscope.io/zh_CN/tutorial/task_long_term_memory.html)
- 基于 Mem0 的长期记忆
	- `agent_control`：智能体通过工具调用自主管理长期记忆。
	- `static_control`：开发者通过编程显式控制长期记忆操作。
- 基于 ReMe 的个人长期记忆

Zep

LangMem

Memobase
- [GitHub - memodb-io/memobase: User Profile-Based Long-Term Memory for AI Chatbot Applications.](https://github.com/memodb-io/memobase)
- [官方- 超越 RAG：Memobase 为 AI 应用注入长期记忆](https://mp.weixin.qq.com/s/Rcst-mC678YmAWwld0vpVQ)
- 特色是使用「非嵌入式数据处理机制」，通过结构化字段（如基本信息、兴趣爱好、行为模式）实现高精度用户画像构建
- 时间感知机制可动态更新用户画像
- 适合需要深度记忆用户的复杂场景
- ![[Pasted image 20260213224859.png]]

MemU
- [GitHub - NevaMind-AI/memU: Memory for 24/7 proactive agents like openclaw (moltbot, clawdbot).](https://github.com/NevaMind-AI/memU)

MemoryOS
- [GitHub - BAI-LAB/MemoryOS: \[EMNLP 2025 Oral\] MemoryOS is designed to provide a memory operating system for personalized AI agents.](https://github.com/BAI-LAB/MemoryOS)



抽取记忆的 prompt 示例


#### Research
代表：
谷歌
- Titans 架构：在 Titans 里，Transformer 的 self-attention（自注意力机制）被明确界定为「短期系统」，而一个独立的神经长期记忆模块，负责跨越上下文窗口、选择性地存储和调用关键信息。
- Hope 架构 Nested Learning: The Illusion of Deep Learning Architectures 
- Evo-Memory benchmark 和 ReMem 框架，明确将长期记忆放入智能体的工作流中考察：模型是否能在连续任务中提炼经验、复盘策略，并在后续任务中真正用上

字节
- MemAgent：通过强化学习训练模型在超长上下文中「学会取舍」，让模型主动形成长期记忆习惯，而不是被动堆叠文本。
	- 长期记忆被拆分进整个工作流，用来保存用户画像、任务状态、阶段性结论，甚至失败经验。训练模型理解哪些信息会影响下一步决策
	- 通过强化学习，让模型在超长上下文和连续任务中逐渐学会「取舍」。模型需要理解哪些信息值得保留，哪些只适合短期使用，甚至哪些应该被主动遗忘。
	- ![[Pasted image 20260213221329.png]]

Minimax 
- 引入独立的记忆层，用于管理长期知识与经验。先解决「装不装得下」，再讨论「该不该留下来」。在这种框架下，长期记忆不再完全依赖于频繁的 RAG 调用，而是通过更大的模型内视野与更少的系统切换，降低整体复杂度。

Deepseek
- Engram 通过把一部分知识转化为Engram存储，能让模型本身的其他参数能更多的学习其他方面的能力。以及说，能发现目前LLM对于这些实体知识的召回需要几层layer才能完成，通过这种直接注入的方式，能够起到增加模型等效深度的效果。

### Benchmark

**locomo数据集**，对记忆体进行评分。
- 使用数据集，根据不同的方案，初始化记忆体；
- 使用问题集，对不用的记忆体，采用相同的 Prompt 和 LLM，获得问题的回复；
- 根据记忆体的问题回复和标准回复，计算 BLEU 分数，也可以让 LLM 再进行一轮推断，得到评估结果。

### 参考
- [Agentic AI基础设施实践经验系列（三）：Agent记忆模块的最佳实践 \| 亚马逊AWS官方博客](https://aws.amazon.com/cn/blogs/china/agentic-ai-infrastructure-deep-practice-experience-thinking-series-three-best-practices-for-agent-memory-module/)
- 
