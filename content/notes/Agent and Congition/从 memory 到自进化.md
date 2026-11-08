阅读材料

- Airbnb: Beyond prompts: measuring and optimizing LLM tool-agent harnesses
- [Harness Engineering for Self-Improvement \| Lil'Log](https://lilianweng.github.io/posts/2026-07-04-harness/)


----

去年半年都在做 agent 的记忆，但是做到后面开始有瓶颈了 
越做越觉得，人怎么这么聪明，agent 怎么就是记不住东西、学习水平非常有限，抓重点和记重点的能力都非常不如人。

---
从 agent 的组成部分说起

---
tool、skill、memory、知识库 的加载机制的一些本质区别

- tool 一般是扩展 agent 的 capability, skill 教的是 know-how 
- tool 一般是原子能力，有格式化输入输出
加载 和 检索路由：在 context 中模型自匹配 or 显示检索
- tool search / defer_loading 
	- tool 除非显示 defer, 会加载完整 schema -- 看下 pi 的 tool 加载机制
	- tool search
		- regex/BM25 工具调用
- skill progressive disclosure
	- 默认只读 name + description 进入 context
	- 然后读 Skill.md，再按需加载里面引用的文件或执行脚本
	- skill 如果还是太多 -- 检索和路由层？

skill 发现成本低所以 context 不是瓶颈，但**选择准确性是**——大规模下和 tool 一样需要一层检索 --- 待确认

---
tool 自进化和 skill 自进化
- tool 有形成标准和类似 skill 社区共享的机制吗，还是各自 agent 设计各自的 tool/插件体系？
- **工具进化在代码层面运作，直接操纵可执行产物**——这与模型进化或记忆进化不同。每个工具形式化为一个三元组 (d, f, π)：自然语言描述、可执行实现、交互协议。
- 为什么工业界做 tool 自进化的不多
	- 安全风险等级 -- Tool 是**新增的可执行代码**——agent 自己写代码、自己注册、自己调用，等于**自己给自己扩权**。
	- 质量验证 -- 一个自动生成的工具改了之后，可能悄悄破坏依赖它的其他工具
	- "能力棘轮"（capability ratchet）- 工具一旦生成、被别的东西依赖，就很难删。而 skill 你可以随时删掉一段 Markdown
	- 可治理性 - Skills 正在成为 LLM agent 的一个**非参数化、可版本管理、可治理的外部策略层**。
- tool 和 skill 自进化的思路大体一致：触发判断（值不值得沉淀）→ 生成 → 验证 → 注册 → 运行时监控 → 迭代/淘汰，有这些区别
	- 验证层面：tool 可以确定性验证：编译、单测、输入输出
	- 依赖图：tool 之间会互相调用、被别的 tool 组合，形成依赖关系，淘汰的成本比 skill 大
- tool的可移植性
	- 内置工具:Read、Write、Edit、Bash、Glob、Grep, 一般运行时各自实现
	- mcp tools/ mcporter: 外部工具，通过mcp协议接入，可跨运行时（跨进程通信、序列化、协议开销）
![[Screenshot 2026-09-05 at 18.38.14.png]]

skill - tool 共进化


---
every thing is a plugin 会是终局吗

dsh 架构分析：everything-is-a-plugin、agent loop 可热替换、profile/插件生态
- 动态生成的插件仅在内存、重启即失、不能自动沉淀为永久插件


---
